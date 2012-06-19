#!/bin/env ruby
# mapper

require 'rubygems'
require 'uuidtools'
require 'iconv'
require 'open-uri'
require './extractcontent'

def is_html?(str)
  /<\s*html/im.match(str[0, 4096])
end

def utf8normalize(str)
  $ic ||= Iconv.new('UTF-8//IGNORE', 'UTF-8')
  $ic.iconv(str)
end

url_list = utf8normalize(STDIN.read)

url_list.split(/[\r\n]+/).each do |line|
  doc_id, url = line.split(/\t/)
  text = utf8normalize(open(url).read)
  if is_html?(text)
    body, title = ExtractContent::analyse(text)
    body = body.split(/[\r\n]+/)
  else
    body, title = text.split(/[\r\n]+/), url
  end

  body.map { |sentence|
    sentence.gsub!(/[\r\n\t\s]+/, ' ')
    if sentence.size > 512
      sentence.gsub(/\s*\.+\s*/, ".\n").split("\n")
    else
      sentence
    end
  }.flatten.map(&:strip).each do |sentence|
    puts [doc_id, UUIDTools::UUID.timestamp_create, sentence].join("\t") unless sentence == ''
  end
end
