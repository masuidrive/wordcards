
require 'rubygems'
require 'mongo'

@db = Mongo::Connection.new.db('sample1')

@docs_coll = @db['documents']
@docs_coll.create_index([[:url, 1], [:user_id, 1]], :unique => true)

@sentences_coll = @db['sentences']

@tokens_coll = @db['tokens']

@docs_coll.remove
@sentences_coll.remove
@tokens_coll.remove
