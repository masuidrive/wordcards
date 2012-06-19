#!/bin/env ruby
# reducer

class StopWordDictonary
  def initialize(names=[])
    load_stopword_files(names)
  end

  def is_stopword?(word)
    return true if word.size <= 2
    @stopwords.include?(word)
  end

  private
  def load_stopword_files(names=[])
    @stopwords = []
    if names.size > 0
      names.each do |filename|
        @stopwords += load_stopword_file(File.dirname(__FILE__)+"/stopwords/#{filename}.txt")
      end
    else
      Dir.glob(File.dirname(__FILE__)+"/stopwords/*.txt").each do |filename|
        @stopwords += load_stopword_file(filename)
      end
    end
  end

  private
  def load_stopword_file(filename)
    open(filename).read.split(/[\r\n]+/).map { |line|
        line.strip!
        line = '' if line[0, 1] == '#'
        line.empty? ? nil : line
      }.compact
  rescue
    []
  end
end

if $0 == __FILE__
  stopwords = StopWordDictonary.new(ARGV)
  STDIN.each do |line|
    type, doc_id, sentence_id, token_id, base_form = line.split("\t")
    if type == 'token'
      unless stopwords.is_stopword?(base_form)
        puts line
      end
    end
  end
end
