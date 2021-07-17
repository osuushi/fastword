# This script shows that it is impossible to create any password the
# same way out of two different sequences of words from the word list.
require 'json'
WORDS = JSON.parse(File.read(File.join(File.dirname(__FILE__), "words.json")))

# Test words. There's a known ambiguity here for N = 4:
#   aaab|bbc|cde|fga
#   aaa|bbb|ccd|efga
# WORDS = %w(
#   aaa
#   aaab
#   bbb
#   bbc
#   ccd
#   cde
#   efga
#   fga
# )

WORD_COUNT = (ARGV.first || 5).to_i
puts "Checking for #{WORD_COUNT} words"

# Example from the test dictionary above
'''
aaa|bbb|ccd|efga
aaab|bbc|cde|fga

aaa|b
  remainder b
b|bb
  remainder bb
bb|c
  remainder c
c|cd
  remainder cd
cd|e
  remainder e
e|fga
  remainder fga
fga is a word

Note that you only have to seed to the right. It is not necessary to reach
`aaa|bbb|ccd|efga` by seeding from `aaab`, so long as you can reach
`aaab|bbc|cde|fga` by seeding from `aaa`
'''

# Produce all segmentations of
def segmentations(word)
  (word.length - 1).times.map do |i|
    [word[0..i], word[(i+1)..]]
  end
end

# Return one ambiguous sequence of words which can be resegmented starting with
# `left` (which is the remainder of the previous search), or nil if none can be
# found
def check(left, depth, ignore_same_left = false)
  # If depth is zero, then we have a match only if `left` is a word in the dictionary
  if depth.zero?
    if WORDS.include?(left)
      return [left]
    else
      return nil
    end
  end

  # Find all words prefixed by the left remainder
  WORDS.each do |right|
    next if ignore_same_left && right == left
    next unless right.start_with?(left)
    remainder = right[left.length..]
    # puts left + "|" + remainder + " " + depth.to_s
    # Try to find a sequence from the remainder onward
    result = check(remainder, depth - 1)
    if result
      return [left] + result
    end
  end
  return nil
end


WORDS.each do |word|
  # Compute the allowed depth from the word count
  result = check(word, (WORD_COUNT - 1) * 2 , true)
  if result
    puts "Found ambiguous sequence: #{result.join("|")}"
    exit 1
  end
end

puts "No ambiguous sequences found"
