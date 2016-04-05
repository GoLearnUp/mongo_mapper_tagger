# @author Dan Guilak

require 'mongo_mapper'
require 'set'

module MongoMapper
  module Plugins
    module MongoMapperTagger
      extend ActiveSupport::Concern

      included do
        has_many :tags, as: :mongo_taggable, class_name: "MongoMapper::Tag"
      end

      module ClassMethods
        # Returns a query of all objects with a particular tag.
        #
        # @param tag [String] the tag to find
        # @return [Plucky] the query of objects with that tag.
        def by_tag(tag)
          ids = MongoMapper::Tag.where(mongo_taggable_type: self.name, tag: tag).distinct(:mongo_taggable_id)

          where(_id: { '$in': ids })
        end
      end

      # Returns an array of strings of the current tags on the object.
      #
      # @return [Array] an array of strings representing the tags on an object.
      def tag_list
        tags.map(&:tag)
      end

      # Sets the tags on the object using (see #update_tags_from_list!)
      #
      # @param new_tag_list [String] the new delimiter-separated list of tags with which
      #   to update the object.
      def tag_list=(new_tag_list)
        update_tags_from_list!(new_tag_list)

        # Have to reload the tags, otherwise the same ones get saved again.
        tags.reload
      end

      # Takes a new list of tags as a delimited string, adds and removes
      # tags on the object as necessary in order to get the object tags to
      # match the new list.
      #
      # @param new_tag_list [String] the new delimiter-separated list of tags with which
      #    to update the object
      # @param delimiter [String] the delimiter for new_tag_list (default comma)
      def update_tags_from_list!(new_tag_list, delimiter=',')
        old_tag_list = tag_list.to_set
        new_tag_list = new_tag_list.split(delimiter).to_set

        to_remove = (old_tag_list - new_tag_list).to_a
        to_add = (new_tag_list - old_tag_list).to_a

        to_remove.each { |tag| MongoMapper::Tag.remove_by_object_and_tag!(self, tag) }

        to_add.each { |tag| MongoMapper::Tag.add_by_object_and_tag!(self, tag) }
      end

      # Removes a tag from the object.
      #
      # @param tag [String] the tag to remove from the object.
      def remove_tag!(tag)
        MongoMapper::Tag.remove_by_object_and_tag!(self, tag)
      end

      # Adds a tag to the object.
      #
      # @param tag [String] the tag to add to the object.
      def add_tag!(tag)
        MongoMapper::Tag.add_by_object_and_tag!(self, tag)
      end
    end
  end
end
