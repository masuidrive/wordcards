#!/bin/env ruby

require 'rubygems'
require 'stanford-core-nlp'
require 'uuidtools'

jar_path = File.expand_path('./stanford-core-nlp/')+'/'

StanfordCoreNLP.jvm_args = ['-Xmx3g']
StanfordCoreNLP.jar_path = jar_path
StanfordCoreNLP.model_path = jar_path
StanfordCoreNLP.use(:english)

class TextTokenizer
  @@pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse)
    
  def tokenize(paragraph)
    text = StanfordCoreNLP::Text.new(paragraph)
    @@pipeline.annotate(text)
    
    sentences = []
    text.get(:sentences).each do |sentence|
      sentence_begin = sentence.get(:character_offset_begin).to_s.to_i
      sentence_end = sentence.get(:character_offset_end).to_s.to_i
      sentence_text = paragraph[sentence_begin...sentence_end]
      
      sentence_data = {
        :sentence_id => UUIDTools::UUID.timestamp_create,
        :original_text => sentence_text,
        :tokens => []
      }

      pos = 0
      sentence.get(:tokens).each do |token|
        base_form = token.get(:lemma).to_s
        token_begin = token.get(:character_offset_begin).to_s.to_i - sentence_begin
        token_end = token.get(:character_offset_end).to_s.to_i - sentence_begin

        base_form.downcase! if /^[A-Z][a-z]+$/.match(base_form)
        if /^[a-z]{2,24}$/i.match(base_form)
          token_data = {
            :token_id => UUIDTools::UUID.timestamp_create,
            :original_text => token.get(:original_text).to_s,
            :base_form => base_form,
            :part_of_speech => token.get(:part_of_speech).to_s,
            :position => pos,
            :token_begin => token_begin,
            :token_length => token_end - token_begin        
          }
          sentence_data[:tokens] << token_data
          pos += 1
        end
      end
      sentences << sentence_data
    end

    sentences
  end
end

if $0 == __FILE__
  tokenizer = TextTokenizer.new
  STDIN.each do |line|
    doc_id, paragraph_id, text = line.split("\t", 3)
    tokenizer.tokenize(text).each do |sentence|
      puts ["sentence", doc_id, sentence[:sentence_id], sentence[:original_text]].join("\t")
      sentence[:tokens].each do |token|
        puts (["token", doc_id] +
          [:sentence_id, :token_id, :base_form, :part_of_speech, :position, :token_begin, :token_length].map { |key|
            token[key]
          }).join("\t")
      end
    end
  end
end
