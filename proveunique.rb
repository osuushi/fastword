# This script shows that it is impossible to create any password the
# same way out of two different sequences of words from the word list.
require 'json'
WORDS = JSON.parse(File.read(File.join(__dir__, "words.json")))

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
def check(left, is_seed = false)
  $seen = {} if is_seed
  # If we've already seen a prefix, then there are two cases:
  # 1. This is a cycle. There could be a sequence involving this cycle, but if
  #    so, we're guaranteed to find a sequence with the cycle removed.
  # 2. We've already determined that there's no ambiguous sequence for this seed
  #    once you hit this prefix.
  return nil if $seen[left]
  $seen[left] = true

  # If we got an empty prefix, that means we've matched a whole word, which
  # means that the sequence on the call stack is ambiguous.
  if left == ""
    return []
  end

  # Find all words prefixed by the left remainder
  WORDS.each do |right|
    # If this is the seed word (the word passed in at the top level), we'll
    # always find that word in the list. This is a trivial case, and not an
    # ambiguous sequence.
    next if is_seed && right == left
    next unless right.start_with?(left)
    remainder = right[left.length..]
    # Try to find a sequence from the remainder onward
    result = check(remainder)
    if result
      return [left] + result
    end
  end
  return nil
end

found = false
WORDS.each do |word|
  result = check(word, true)
  if result
    found = true
    puts "Found ambiguous sequence: #{result.join("|")}"
  end
end

if found
  exit 1
else
  puts "No ambiguous sequences found"
end
