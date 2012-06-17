require 'rubygems'
require 'mongo'

@conn = Mongo::Connection.new
@db   = @conn['sample1']

@docs_coll = @db['documents']
@sentences_coll = @db['sentences']
@tokens_coll = @db['tokens']
@words_coll = @db['words']
@word_counters_coll = @db['word_counters']

humername = open('dic/personal_name_ja.txt').read.split(/[\s\n]+/m)
humername += open('dic/personal_name_en.txt').read.split(/[\s\n]+/m)
STDERR.puts "Loaded"

@word_counters_coll.find({}, {:limit => 500}).sort(:counter => :desc).each do |wc|
  unless humername.include?(wc['base_form'].downcase)
    puts "\# #{wc['counter']}: #{wc['base_form']}"
    @tokens_coll.find({:_id => {'$in' => wc['tokens'][0..1]}}).each do |t|
      s = @sentences_coll.find_one(t['sentence'])
      puts "- #{s['original_text']}"
    end
    puts ""
  end
end
