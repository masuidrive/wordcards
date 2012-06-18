#!/usr/bin/env ruby
require 'rubygems'
require './extractcontent'
require './tokenize'
require 'open-uri'

# url = "http://www.ruby-lang.org/en/"

url = ARGV[0]

html = open(url).read.encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => ' ')
original_text, title = ExtractContent::analyse(html)
if original_text
  original_text = original_text.split(/\r*\n+/)
else
  original_text = html
end

tokenizer = TextTokenizer.new
doc = tokenizer.tokenize(original_text, title)
doc[:url] = url

require 'json'
puts JSON.generate(doc)

=begin
doc_id = @docs_coll.insert({:url => url, :title => title})

doc[:sentences].each do |s|
  sentence_id = s[:_id] = BSON::ObjectId.new
  word_keys = []
  s[:tokens].each do |t|
    word_key = [t[:part_of_speech][0],t[:base_form]].join(':')
    unless stop_words.include?(t[:base_form]) || word_keys.include?(word_key)
      exists_word = @words_coll.find_one(:word_key => word_key)
      word_id = if exists_word
        exists_word['_id']
      else
        @words_coll.insert({:word_key => word_key})
      end
      token_id = @tokens_coll.insert({
        :word => word_id,
        :base_form => t[:base_form],
        :part_of_speech => t[:part_of_speech],
        :sentence => sentence_id,
        :sentence_token_offset => t[:token_begin],
        :sentence_token_length => t[:token_length]
      })
      @word_counters_coll.insert({
        :word => word_id,
        :base_form => t[:base_form],
        :part_of_speech => t[:part_of_speech],
        :tokens => [],
        :counter => 0
      })
      @word_counters_coll.update({
        :word => word_id
      },
      {
        '$inc' => {:counter => 1},
        '$push' => {:tokens => token_id}
      })
      word_keys << word_key
    end
  end
  @sentences_coll.insert s
end
=end