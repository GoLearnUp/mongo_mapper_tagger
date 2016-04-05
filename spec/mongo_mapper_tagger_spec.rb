require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MongoMapper::Plugins::MongoMapperTagger do
  context "instance methods" do
    before(:each) do
      @taggable = Taggable.create()
    end

    it "should respond to all taggable methods" do
      MongoMapper::Plugins::MongoMapperTagger.instance_methods.each do |instance_method|
        expect(@taggable.respond_to?(instance_method)).to be true
      end
    end

    describe "#add_tag!" do
      it "should add a tag" do
        @taggable.add_tag!('pretty-cool')
        @taggable.reload

        expect(@taggable.tags.count).to eq(1)
      end
    end

    describe "#remove_tag!" do
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

    describe "#tag_list" do
      before do
        @tags = [ 'hey', 'you' ]

        @tags.each { |tag| @taggable.add_tag!(tag) }
      end

      it "should return a csv string of the tags" do
        expect(@taggable.tag_list).to eq @tags
      end
    end

    describe "#tag_list=" do
      it "should call update_tags_from_list!" do
        allow(@taggable).to receive(:update_tags_from_list!)

        expect(@taggable.tags).to receive(:reload)
        expect(@taggable).to receive(:update_tags_from_list!)

        @taggable.tag_list=('one,two,three')
      end
    end

    describe "#update_tags_from_list!" do
      before do
        @old_tag_names = [ 'aged', 'old', 'vintage' ]
        @new_tag_names = [ 'old', 'vintage', 'neo' ]

        @old_tag_names.each { |tag| @taggable.add_tag!(tag) }
      end

      it "should add the new tags and remove the old tags" do
        @taggable.update_tags_from_list!(@new_tag_names.join(','))
        @taggable.reload

        expect(@taggable.tag_list).to eq([ 'old', 'vintage', 'neo' ])
      end
    end
  end

  context "class methods" do
    before do
      @taggable_1 = Taggable.create()
      @taggable_2 = Taggable.create()

      @tags = [ 'hey', 'you', 'kids', 'get', 'off', 'my', 'lawn' ]
      @tags.each { |tag| @taggable_1.add_tag!(tag) }

      @tags.first(3).each { |tag| @taggable_2.add_tag!(tag) }
    end

    describe "by_tag" do
      it "should return taggables with the given tag" do
        expect(Taggable.by_tag(@tags.first).distinct(:_id)).to eq [@taggable_1.id, @taggable_2.id]
      end

      it "should return only one taggable if there is only one with that tag" do
        expect(Taggable.by_tag(@tags.last).distinct(:_id)).to eq [@taggable_1.id]
      end

      it "should return nothing if the tag is not present" do
        expect(Taggable.by_tag('not-a-tag').distinct(:_id)).to eq []
      end
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
      allow(MongoMapper::Tag).to receive(:add_by_type_and_id_and_tag!).and_raise(Exception)

      expect(lambda {
        MongoMapper::Tag.add_by_object_and_tag!(@taggable, @first_tag_name)
      }).to raise_exception(Exception)
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
