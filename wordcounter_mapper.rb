#!/bin/env ruby
# mapper

require './stopword_filter'

stopwords = StopWordDictonary.new(ARGV)
STDIN.each do |line|
  type, doc_id, sentence_id, token_id, base_form, part_of_speech, index, count = line.split("\t")
  if type == 'token'
    unless stopwords.is_stopword?(base_form)
      puts [part_of_speech[0,1]+base_form, 1].join("\t") if count.to_i == 1
    end
  end
end
