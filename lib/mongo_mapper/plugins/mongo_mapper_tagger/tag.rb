class MongoMapper::Tag
  class TagNotFound < StandardError; end

  include MongoMapper::Document

  key :tag, String, required: true

  ensure_index :tag
  ensure_index :mongo_taggable_type
  ensure_index :mongo_taggable_id

  belongs_to :mongo_taggable, polymorphic: true

  validates_uniqueness_of :tag, scope: [ :mongo_taggable_id, :mongo_taggable_type ]

  class << self
    def remove_by_type_and_id_and_tag!(taggable_type, taggable_id, tag_name)
      success = remove_by_type_and_id_and_tag(taggable_type, taggable_id, tag_name)

      raise TagNotFound unless success
    end

    def remove_by_type_and_id_and_tag(taggable_type, taggable_id, tag_name)
      tag = first(mongo_taggable_type: taggable_type, mongo_taggable_id: taggable_id, tag: tag_name)

      return false unless tag.present?

      success = tag.destroy
      success && success["ok"] == 1
    end

    def add_by_type_and_id_and_tag!(taggable_type, taggable_id, tag_name)
      create!(mongo_taggable_type: taggable_type, mongo_taggable_id: taggable_id, tag: tag_name)
    end

    def add_by_type_and_id_and_tag(taggable_type, taggable_id, tag_name)
      find_args = {
        mongo_taggable_type: taggable_type,
        mongo_taggable_id: taggable_id,
        tag: tag_name,
      }

      # `create` will return the object if it finds it, rather than returning false.
      if first(find_args).present?
        return false
      end

      success = create(find_args)

      success.present?
    end

    def remove_by_object_and_tag!(object, tag_name)
      remove_by_type_and_id_and_tag!(object.class.name, object.id, tag_name)
    end

    def remove_by_object_and_tag(object, tag_name)
      remove_by_type_and_id_and_tag(object.class.name, object.id, tag_name)
    end

    def add_by_object_and_tag(object, tag_name)
      add_by_type_and_id_and_tag(object.class.name, object.id, tag_name)
    end

    def add_by_object_and_tag!(object, tag_name)
      add_by_type_and_id_and_tag!(object.class.name, object.id, tag_name)
    end
  end
end
