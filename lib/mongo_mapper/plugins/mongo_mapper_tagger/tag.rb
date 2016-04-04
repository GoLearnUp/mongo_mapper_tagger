# @author Dan Guilak

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
    # Removes a tag by the type of the object, the id of the object, and the tag name.
    # Raises an error if the tag wasn't found.
    #
    # @param taggable_type [String] the type (class name) of the object.
    # @param taggable_id [String] the BSON ID of the object.
    # @param tag_name [String] the name of the tag to remove.
    def remove_by_type_and_id_and_tag!(taggable_type, taggable_id, tag_name)
      success = remove_by_type_and_id_and_tag(taggable_type, taggable_id, tag_name)

      raise TagNotFound unless success
    end

    # Removes a tag by the type of the object, the id of the object, and the tag name.
    #
    # @param taggable_type [String] the type (class name) of the object.
    # @param taggable_id [String] the BSON ID of the object.
    # @param tag_name [String] the name of the tag to remove.
    # @return [Boolean] true if successful, false if not
    def remove_by_type_and_id_and_tag(taggable_type, taggable_id, tag_name)
      tag = first(mongo_taggable_type: taggable_type, mongo_taggable_id: taggable_id, tag: tag_name)

      return false unless tag.present?

      success = tag.destroy
      success && success["ok"] == 1
    end

    # Adds a tag by the type of the object, the id of the object, and the tag name.
    # Raises an error if the tag wasn't created successfully.
    #
    # @param taggable_type [String] the type (class name) of the object.
    # @param taggable_id [String] the BSON ID of the object.
    # @param tag_name [String] the name of the tag to add.
    def add_by_type_and_id_and_tag!(taggable_type, taggable_id, tag_name)
      create!(mongo_taggable_type: taggable_type, mongo_taggable_id: taggable_id, tag: tag_name)
    end

    # Adds a tag by the type of the object, the id of the object, and the tag name.
    #
    # @param taggable_type [String] the type (class name) of the object.
    # @param taggable_id [String] the BSON ID of the object.
    # @param tag_name [String] the name of the tag to add.
    # @return [Boolean] true if successful, false if not
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

    # Removes a tag on an object.
    # Raises if the tag isn't found.
    #
    # @param object [Object] object from which to remove the tag
    # @param tag_name [String] tag to remove from the object.
    def remove_by_object_and_tag!(object, tag_name)
      remove_by_type_and_id_and_tag!(object.class.name, object.id, tag_name)
    end

    # Removes a tag on an object.
    #
    # @param object [Object] object from which to remove the tag
    # @param tag_name [String] tag to remove from the object.
    # @return [Boolean] true if successful, false if not
    def remove_by_object_and_tag(object, tag_name)
      remove_by_type_and_id_and_tag(object.class.name, object.id, tag_name)
    end

    # Adds a tag on an object.
    #
    # @param object [Object] object from which to remove the tag
    # @param tag_name [String] tag to add to the object.
    def add_by_object_and_tag(object, tag_name)
      add_by_type_and_id_and_tag(object.class.name, object.id, tag_name)
    end

    # Adds a tag on an object.
    # Raises if the tag wasn't successfully created.
    #
    # @param object [Object] object on which to add the tag
    # @param tag_name [String] tag to add to the object.
    def add_by_object_and_tag!(object, tag_name)
      add_by_type_and_id_and_tag!(object.class.name, object.id, tag_name)
    end
  end
end
