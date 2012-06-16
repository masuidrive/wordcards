require 'rubygems'
require './extractcontent'
require './tokenize'
require './stop_words'
require 'mongo'
require 'open-uri'

@conn = Mongo::Connection.new
@db   = @conn['sample1']

@docs_coll = @db['documents']
@sentences_coll = @db['sentences']
@tokens_coll = @db['tokens']
@words_coll = @db['words']
@word_counters_coll = @db['word_counters']

@docs_coll.remove
@sentences_coll.remove
@tokens_coll.remove
@words_coll.remove
@word_counters_coll.remove
@word_counters_coll.create_index(:word, :unique => true)
@word_counters_coll.create_index([[:counter, -1]])


#url = "http://guides.rubyonrails.org/getting_started.html"
#url = "https://github.com/rails/rails/blob/master/activerecord/CHANGELOG.md"
url = "http://www.ruby-lang.org/en/"
#url = 'sample1.txt'

html = open(url).read.encode("UTF-8")
original_text, title = ExtractContent::analyse(html)
if original_text
  original_text.gsub!(/\r*\n+/,'. ')
else
  original_text = html
end
puts "--------"
puts original_text
puts "--------"
puts ""

tokenizer = TextTokenizer.new
doc = tokenizer.tokenize(original_text, title)
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


@word_counters_coll.find({}, {:limit => 100}).sort(:counter => :desc).each do |wc|
  puts "#{wc['counter']}: #{wc['base_form']}"
  @tokens_coll.find({:_id => {'$in' => wc['tokens'][0..1]}}).each do |t|
    s = @sentences_coll.find_one(t['sentence'])
    puts " - #{s['original_text']}"
  end
end
