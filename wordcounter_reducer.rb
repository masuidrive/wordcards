#!/bin/env ruby
# reducer

word_count = Hash.new(0)
STDIN.each do |line|
  word, count = line.split("\t")
  word_count[word] += count.to_i
end

word_count.each do |word, count|
  puts [word, count].join("\t")
end