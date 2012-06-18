require 'rubygems'
require './stop_words'
require './mongo_config'
require 'open-uri'
require 'json'

doc = JSON.parse(STDIN.read)

user_id = ARGV[0] || 'guest'

doc_id = @docs_coll.insert({
  :url => doc['url'],
  :title => doc['title'],
  :user_id => user_id
}, :safe => true)

doc['sentences'].each do |sentence|
  word_keys = []
  sentence['_id'] = BSON::ObjectId.new
  sentence['tokens'].each do |t|
    word_key = [t['part_of_speech'][0], t['base_form']].join(':')
    unless stop_words.include?(t['base_form']) || word_keys.include?(word_key)
      token_id = @tokens_coll.insert({
        :user_id => user_id,
        
        :word_key => word_key,
        :base_form => t['base_form'],
        :part_of_speech => t['part_of_speech'],

        :sentence => sentence['_id'],
        :sentence_token_offset => t['token_begin'],
        :sentence_token_length => t['token_length'],

        :document => doc_id,
        :document_categories => []
      })
      word_keys << word_key
    end
  end
  @sentences_coll.insert sentence
end
