require 'rubygems'
require 'stanford-core-nlp'
require 'uuidtools'

StanfordCoreNLP.jvm_args = ['-Xmx3g']
StanfordCoreNLP.use(:english)


class TextTokenizer
  @@pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse)

  def tokenize(original_text, title="No titled")
    text = StanfordCoreNLP::Text.new(original_text)
    @@pipeline.annotate(text)

    title = ARGV[0] || "No title"

    document_uuid = UUIDTools::UUID.timestamp_create.to_s
    document = {
      :document_uuid => document_uuid,
      :title => title
    }
    sentences = []

    text.get(:sentences).each do |sentence|
      sentence_uuid = UUIDTools::UUID.timestamp_create.to_s
      sentence_begin = sentence.get(:character_offset_begin).to_s.to_i
      sentence_end = sentence.get(:character_offset_end).to_s.to_i
      sentence_text = original_text[sentence_begin...sentence_end]
      
      sentence_data = {
        :sentence_uuid => sentence_uuid,
        :document_uuid => document_uuid,
        :original_text => sentence_text,
        :tokens => []
      }

      sentence.get(:tokens).each do |token|
        base_form = token.get(:lemma).to_s
        token_begin = token.get(:character_offset_begin).to_s.to_i - sentence_begin
        token_end = token.get(:character_offset_end).to_s.to_i - sentence_begin

        base_form.downcase! if /^[A-Z][a-z]+$/.match(base_form)
        if /^[a-z]{2,20}$/i.match(base_form)
          token_uuid = UUIDTools::UUID.timestamp_create.to_s
          token_data = {
            :token_uuid => token_uuid,
            :document_uuid => document_uuid,
            :sentence_uuid => sentence_uuid,
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
    document[:sentences] = sentences
    document
  end
end

if $0 == __FILE__
  # usage: echo "This is a pen" | ruby tokenizer.rb "Sample"
  require 'json'
  tokenizer = TextTokenizer.new
  doc = tokenizer.tokenize(STDIN.read, ARGV[0] || 'No titled')
  puts JSON.generate(doc)
end
