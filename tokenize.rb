require 'rubygems'
require 'stanford-core-nlp'

StanfordCoreNLP.jvm_args = ['-Xmx3g']
StanfordCoreNLP.use(:english)


class TextTokenizer
  @@pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse)
    
  def tokenize(original_text, title="No titled")
    original_text = original_text.split(".") unless original_text.is_a?(Array)

    document = {}
    sentences = []

    original_text.each do |ot|
      text = StanfordCoreNLP::Text.new(ot)
      @@pipeline.annotate(text)
      
      text.get(:sentences).each do |sentence|
        sentence_begin = sentence.get(:character_offset_begin).to_s.to_i
        sentence_end = sentence.get(:character_offset_end).to_s.to_i
        sentence_text = ot[sentence_begin...sentence_end]
        
        sentence_data = {
          :original_text => sentence_text,
          :tokens => []
        }

        sentence.get(:tokens).each do |token|
          base_form = token.get(:lemma).to_s
          token_begin = token.get(:character_offset_begin).to_s.to_i - sentence_begin
          token_end = token.get(:character_offset_end).to_s.to_i - sentence_begin

          base_form.downcase! if /^[A-Z][a-z]+$/.match(base_form)
          if /^[a-z]{3,24}$/i.match(base_form)
            token_data = {
              :original_text => token.get(:original_text).to_s,
              :base_form => base_form,
              :part_of_speech => token.get(:part_of_speech).to_s,
              :token_begin => token_begin,
              :token_length => token_end - token_begin        
            }
            sentence_data[:tokens] << token_data
          end
        end
        sentences << sentence_data
      end
    end
    document[:sentences] = sentences
    document
  end
end

if $0 == __FILE__
  # usage: echo "This is a pen" | ruby tokenizer.rb "Sample"
  require 'json'
  tokenizer = TextTokenizer.new
  doc = tokenizer.tokenize(STDIN.read)
  puts doc.to_json
end
