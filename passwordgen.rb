#!/usr/bin/env ruby

require 'securerandom'
require 'json'
WORDS = JSON.parse(File.read(File.join(File.dirname(__FILE__), "words.json")))

def randword
  WORDS[SecureRandom.rand(WORDS.length)]
end

WORD_COUNT = 5

password = WORD_COUNT.times.map { randword }.map(&:capitalize).join("")
puts password
puts "Entropy: #{WORD_COUNT*Math.log2(WORDS.length)}"
