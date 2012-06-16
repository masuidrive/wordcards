require 'rubygems'
require './extractcontent'
require 'open-uri'
require 'stanford-core-nlp'
StanfordCoreNLP.jvm_args = ['-Xmx3g']


stop_words = %w(a all at as and by or on into from in to for the with it you he she they I we will of this that be can)
# ruby stop words
stop_words += %w(rb gem class ensure nil self when def false not super while for or then  and do if redo true line begin else in  undef file break elsif module retry unless encoding case end next return until)
stop_words += %w(html css href tag web form id link db url log doc URL HTML)
stop_words += open('stopwords1.txt').read.split(/\n/).map{|s| s.strip} rescue []
stop_words += open('stopwords2.txt').read.split(/\n/).map{|s| s.strip} rescue []
stop_words += open('stopwords3.txt').read.split(/\n/).map{|s| s.strip} rescue []
stop_words.uniq!

StanfordCoreNLP.use(:english)
#StanfordCoreNLP.set_model('pos.model', 'english-left3words-distsim.tagger')
#StanfordCoreNLP.set_model('parser.model', 'englishPCFG.ser.gz')
#StanfordCoreNLP.load_class('MaxentTagger', 'edu.stanford.nlp.tagger') 


pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse)

#url = "http://guides.rubyonrails.org/getting_started.html"
url = "https://github.com/rails/rails/blob/master/activerecord/CHANGELOG.md"
#url = "http://www.ruby-lang.org/en/"

html = open(url).read.encode("UTF-8")
original_text, title = ExtractContent::analyse(html)

text = StanfordCoreNLP::Text.new(original_text)
#text = StanfordCoreNLP::Text.new("This is a pen. I used it.")
pipeline.annotate(text)

words = []
text.get(:tokens).each do |token|
  base_form = token.get(:lemma).to_s
  base_form.downcase! if /^[A-Z][a-z]+$/.match(base_form)
  words << base_form if /^[a-z]{2,20}$/i.match(base_form)
end

word_count = Hash.new(0)
(words - stop_words).each do |w|
  word_count[w] += 1
end

puts words.join(' ')
puts "-----"
word_count.to_a.sort{|a, b| a[1] <=> b[1]}.reverse.each do |w|
  puts "%4d: %s" % [w[1], w[0]]
end


#end