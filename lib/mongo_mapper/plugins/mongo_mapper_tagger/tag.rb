class MongoMapper::Tag
  include MongoMapper::Document

  key :tag, String, required: true

  ensure_index :tag
  ensure_index :mongo_taggable_type
  ensure_index :mongo_taggable_id

  belongs_to :mongo_taggable, polymorphic: true

  class << self
    def remove_by_type_and_id_and_tag!(type, id, tag_name)
      success = remove_by_type_and_id_and_tag(type, id, tag_name)

      raise MongoMapper::DocumentNotFound unless success
    end

    def remove_by_type_and_id_and_tag(type, id, tag_name)
      tag = find_one(mongo_taggable_type: type, mongo_taggable_id: id, tag: tag_name)

      if tag.present?
        tag.destroy
      else
        false
      end
    end

    def add_by_type_and_id_and_tag!(type, id, tag_name)
      success = add_by_type_and_id_and_tag(type, id, tag_name)

      raise MongoMapper::DocumentNotFound unless success
    end

    def add_by_type_and_id_and_tag(type, id, tag_name)
      create(mongo_taggable_type: type, mongo_taggable_id: id, tag: tag_name)
    end

    def remove_by_object_and_tag!(object, tag_name)
      success = remove_by_object_and_tag(object, tag_name)

      raise MongoMapper::DocumentNotFound unless success
    end

    def remove_by_object_and_tag(object, tag_name)
      tag = find_one(mongo_taggable_type: object.class.name, mongo_taggable_id: object.id, tag: tag_name)

      if tag.present?
        tag.destroy
      else
        false
      end
    end

    def add_by_object_and_tag(object, tag_name)
      create(mongo_taggable_type: object.class.name, mongo_taggable_id: object.id, tag: tag_name)
    end

    def add_by_object_and_tag!(object, tag_name)
      success = add_by_object_and_tag(object, tag_name)

      raise MongoMapper::DocumentNotFound unless success
    end
  end
end
