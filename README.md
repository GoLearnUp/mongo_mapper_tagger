<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#orgheadline1">1. MongoMapper Tagger</a></li>
<li><a href="#orgheadline2">2. Installation</a></li>
<li><a href="#orgheadline3">3. Documentation</a></li>
</ul>
</div>
</div>

# MongoMapper Tagger<a id="orgheadline1"></a>

`mongo_mapper_tagger` is a dead-simple tagging system for [MongoMapper](https://github.com/mongomapper/mongomapper).

It provides user-agnostic unique tags for models.

**Note**: MongoMapper Tagger is very much a work in progress. Let me know if you find bugs/feel free to open a PR!

Tested on Ruby 2.2.2 with MongoMapper 0.13.1

# Installation<a id="orgheadline2"></a>

It's as simple as a `gem install mongo_mapper_tagger` and including `plugin MongoMapper::Plugins::MongoMapperTagger` on
the model you want to enable tagging for:

```ruby
class PhoneNumber
  include MongoMapper::Document
  plugin MongoMapper::Plugins::MongoMapperTagger

  ...
end
```

# Documentation<a id="orgheadline3"></a>

Currently located at [RubyDoc](http://www.rubydoc.info/github/GoLearnUp/mongo_mapper_tagger/)
