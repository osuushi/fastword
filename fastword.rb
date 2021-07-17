#!/usr/bin/env ruby

require 'securerandom'
require 'json'
WORDS = JSON.parse(File.read(File.join(__dir__, "words.json")))

def randword
  WORDS[SecureRandom.rand(WORDS.length)]
end

WORD_COUNT = (ARGV.first || 5).to_i

password = WORD_COUNT.times.map { randword }.join(" ")
puts password
puts "Entropy: #{WORD_COUNT*Math.log2(WORDS.length)}"
