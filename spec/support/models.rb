class Taggable
  include MongoMapper::Document
  plugin MongoMapper::Plugins::MongoMapperTagger
end
