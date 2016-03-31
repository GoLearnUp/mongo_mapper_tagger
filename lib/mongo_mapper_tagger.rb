require 'mongo_mapper'

module MongoMapper
  autoload :Tag, 'mongo_mapper/plugins/mongo_mapper_tagger/tag'

  module Plugins
    autoload :MongoMapperTagger, 'mongo_mapper/plugins/mongo_mapper_tagger'
  end
end
