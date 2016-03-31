require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "MongoMapper::Plugins::MongoMapperTagger" do
  before(:each) do
    @taggable = Taggable.create()
  end

  it "should respond to all taggable methods" do
    # TODO: A better way to do this? Go through all methods on MongoMapperTagger?
    expect(@taggable.respond_to?(:add_tag!)).to be true
    expect(@taggable.respond_to?(:remove_tag!)).to be true
    expect(@taggable.respond_to?(:tag_list)).to be true
    expect(@taggable.respond_to?(:tag_list)).to be true
  end

  describe "add_tag!" do
    it "should add a tag" do
      @taggable.add_tag!('pretty-cool')
      @taggable.reload

      expect(@taggable.tags.count).to eq(1)
    end
  end

  describe "remove_tag!" do
    before do
      @taggable.add_tag!('pretty-cool')
      @taggable.reload
    end

    it "should remove a tag" do
      expect(@taggable.tags.count).to eq(1)

      @taggable.remove_tag!('pretty-cool')
      @taggable.reload

      expect(@taggable.tags.count).to eq(0)
    end
  end
end

describe "MongoMapper::Tag" do
  before(:each) do
    @taggable = Taggable.create()

    @first_tag_name = "you-the-best"
    @tag = MongoMapper::Tag.create({
      tag: @first_tag_name,
      mongo_taggable_type: @taggable.class.name,
      mongo_taggable_id: @taggable.id,
    })
  end

  describe "remove_by_type_and_id_and_tag!" do
    it "should not raise if the tag is removed successfully" do
      allow(MongoMapper::Tag).to receive(:remove_by_type_and_id_and_tag) { true }

      args = [
        "Taggable",
        @taggable.id,
        @first_tag_name
      ]

      expect(MongoMapper::Tag).to receive(:remove_by_type_and_id_and_tag).with(*args)

      MongoMapper::Tag.remove_by_type_and_id_and_tag!(*args)
    end

    it "should raise if the remove_by_type_and_id_and_tag is unsuccessful" do
      allow(MongoMapper::Tag).to receive(:remove_by_type_and_id_and_tag) { false }

      expect(lambda {
        MongoMapper::Tag.remove_by_type_and_id_and_tag!("Taggable", @taggable.id, "nope")
      }).to raise_error(MongoMapper::Tag::TagNotFound)
    end
  end

  describe "remove_by_type_and_id_and_tag" do
    it "should remove the tag" do
      expect(MongoMapper::Tag.count).to eq(1)

      args = [
        "Taggable",
        @taggable.id,
        @first_tag_name
      ]

      expect(MongoMapper::Tag.remove_by_type_and_id_and_tag(*args)).to eq(true)

      expect(MongoMapper::Tag.count).to eq(0)
    end

    it "should return false if the tag isn't present" do
      expect(MongoMapper::Tag.remove_by_type_and_id_and_tag("Taggable", @taggable.id, "nope")).to eq(false)
    end

    it "should return false if the destroy is unsuccessful" do
      allow_any_instance_of(MongoMapper::Tag).to receive(:destroy) { { "ok": 0 } }

      expect(MongoMapper::Tag.remove_by_type_and_id_and_tag("Taggable", @taggable.id, @first_tag_name)).to eq(false)

      expect(MongoMapper::Tag.count).to eq(1)
    end
  end

  describe "remove_by_object_and_tag!" do
    it "should not raise if the tag is removed successfully" do
      allow(MongoMapper::Tag).to receive(:remove_by_type_and_id_and_tag!) { true }

      expanded_args = [
        @taggable.class.name,
        @taggable.id,
        @first_tag_name
      ]

      expect(MongoMapper::Tag).to receive(:remove_by_type_and_id_and_tag!).with(*expanded_args)

      expect(lambda {
        MongoMapper::Tag.remove_by_object_and_tag!(@taggable, @first_tag_name)
      }).not_to raise_exception
    end

    it "should raise if the remove_by_object_and_tag is unsuccessful" do
      allow(MongoMapper::Tag).to receive(:remove_by_type_and_id_and_tag!).and_raise(MongoMapper::Tag::TagNotFound)

      expect(lambda {
        MongoMapper::Tag.remove_by_object_and_tag!(@taggable, "nope")
      }).to raise_error(MongoMapper::Tag::TagNotFound)
    end
  end

  describe "remove_by_object_and_tag" do
    it "should remove the tag" do
      allow(MongoMapper::Tag).to receive(:remove_by_type_and_id_and_tag) { true }

      expanded_args = [
        @taggable.class.name,
        @taggable.id,
        @first_tag_name
      ]

      expect(MongoMapper::Tag).to receive(:remove_by_type_and_id_and_tag).once.with(*expanded_args)

      expect(MongoMapper::Tag.remove_by_object_and_tag(@taggable, @first_tag_name)).to eq(true)
    end

    it "should return false if the tag isn't present" do
      allow(MongoMapper::Tag).to receive(:remove_by_type_and_id_and_tag) { false }

      expect(MongoMapper::Tag.remove_by_object_and_tag(@taggable, "nope")).to eq(false)
    end
  end

  describe "add_by_type_and_id_and_tag!" do
    it "should not raise if the tag is added successfully" do
      expanded_args = [
        @taggable.class.name,
        @taggable.id,
        "one-more-time"
      ]

      expect(MongoMapper::Tag).to receive(:add_by_type_and_id_and_tag!).once.with(*expanded_args)

      expect(lambda {
        MongoMapper::Tag.add_by_type_and_id_and_tag!(*expanded_args)
      }).not_to raise_exception
    end

    it "should raise if it is a duplicate tag" do
      expect(lambda {
        MongoMapper::Tag.add_by_type_and_id_and_tag!(@taggable.class.name, @taggable.id, @first_tag_name)
      }).to raise_exception(MongoMapper::DocumentNotValid)
    end
  end

  describe "add_by_type_and_id_and_tag" do
    it "should add the tag" do
      expanded_args = [
        @taggable.class.name,
        @taggable.id,
        "one-more-time"
      ]

      expect(MongoMapper::Tag.add_by_type_and_id_and_tag(*expanded_args)).to eq(true)
    end

    it "should return false if the create is unsuccessful with duplicate tag" do
      expanded_args = [
        @taggable.class.name,
        @taggable.id,
        @first_tag_name
      ]

      expect(MongoMapper::Tag.add_by_type_and_id_and_tag(*expanded_args)).to eq(false)
    end
  end

  describe "add_by_object_and_tag!" do
    it "should not raise if the tag is added successfully" do
      allow(MongoMapper::Tag).to receive(:add_by_type_and_id_and_tag!) { true }

      expanded_args = [
        @taggable.class.name,
        @taggable.id,
        "one-more-time"
      ]

      expect(MongoMapper::Tag).to receive(:add_by_type_and_id_and_tag!).once.with(*expanded_args)

      expect(lambda {
        MongoMapper::Tag.add_by_object_and_tag!(@taggable, "one-more-time")
      }).not_to raise_exception
    end

    it "should raise if it is a duplicate tag" do
      allow(MongoMapper::Tag).to receive(:add_by_type_and_id_and_tag!).and_raise(MongoMapper::DocumentNotValid)

      # byebug

      expect(lambda {
        MongoMapper::Tag.add_by_object_and_tag!(@taggable, @first_tag_name)
      }).to raise_exception(MongoMapper::DocumentNotValid)
    end
  end

  describe "add_by_object_and_tag" do
    it "should return true if the tag is added successfully" do
      allow(MongoMapper::Tag).to receive(:add_by_type_and_id_and_tag) { true }

      expanded_args = [
        @taggable.class.name,
        @taggable.id,
        "one-more-time"
      ]

      expect(MongoMapper::Tag).to receive(:add_by_type_and_id_and_tag).once.with(*expanded_args)

      expect(MongoMapper::Tag.add_by_object_and_tag(@taggable, "one-more-time")).to be true
    end

    it "should return false if it is a duplicate tag" do
      allow(MongoMapper::Tag).to receive(:add_by_type_and_id_and_tag) { false }

      expect(MongoMapper::Tag.add_by_object_and_tag(@taggable, @first_tag_name)).to be false
    end
  end
end
