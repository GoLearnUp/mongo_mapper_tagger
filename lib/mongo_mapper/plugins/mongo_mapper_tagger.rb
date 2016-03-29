require File.join(File.dirname(__FILE__), 'mongo_mapper_tagger', 'tag')

require 'mongo_mapper'
require 'set'

module MongoMapper
  module Plugins
    module MongoMapperTagger
      extend ActiveSupport::Concern

      included do
        has_many :tags, as: :mongo_taggable, class_name: "MongoMapper::Tag"

        before_validation :clean_tags
      end

      module ClassMethods
        def by_tag(tag)
          ids = MongoMapper::Tag.where(mongo_taggable_type: self.name, tag: tag).distinct(:mongo_taggable_id)

          where(_id: { '$in': ids })
        end
      end

      def tag_list
        tags.map(&:tag)
      end

      def tag_list=(new_tag_list)
        update_tags_from_list!(new_tag_list)
      end

      # Takes tags as a csv string, this will
      # diff the new list with the old and creates/destroys
      # as necessary.
      def update_tags_from_list!(new_tag_list, delimiter=',')
        # TODO: Fail correctly
        old_tag_list = tag_list.to_set
        new_tag_list = new_tag_list.split(delimiter).to_set

        to_remove = (old_tag_list - new_tag_list).to_a
        to_add = (new_tag_list - old_tag_list).to_a

        to_remove.each { |tag| MongoMapper::Tag.remove_by_object_and_tag!(self, tag) }

        to_add.each { |tag| MongoMapper::Tag.add_by_object_and_tag!(self, tag) }
      end

      def remove_tag!(tag)
        MongoMapper::Tag.remove_by_object_and_tag!(self, tag)
      end

      def add_tag!(tag)
        MongoMapper::Tag.add_by_object_and_tag!(self, tag)
      end

    private

      def clean_tags
      end
    end
  end
end
