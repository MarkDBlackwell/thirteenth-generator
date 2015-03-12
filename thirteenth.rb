class Chord
  attr_reader :bitstring, :chord

  def initialize(a)
#print 'a='
#p a
    @chord = a
    @bitstring = generate_bitstring
  end

  def highest_pitch_octaveless
    @chord.last % SCALE_LENGTH
  end

  def lowest_pitch_octaveless
    @chord.first % SCALE_LENGTH
  end

  def lilypond
    beginning = '< '
    ending    = ' >'
    s = @chord.map do |e|
      letter = NAMES.at(e % SCALE_LENGTH)
      adjusted_note = e + ADJUSTMENT_FOR_OCTAVE_BREAKS_AT_C
      octave = OCTAVES.at(adjusted_note.div SCALE_LENGTH)
      letter + octave
    end
    "#{beginning}#{s.join ' '}#{ending}\n"
  end

  private

  def generate_bitstring
    result = 0
    @chord.each do |e|
# 5 to 28 becomes 23 to 0:
      bit_number = -e + 28
      result += 2 ** bit_number
    end
    result
  end
end

def exclude(chords, exclusions)
  chords.select do |chord|
    bad_contained = exclusions.map do |a|
      present = (chord + a).uniq.length == SCALE_LENGTH
      present ? true : nil
    end
    bad_contained.compact.empty?
  end
end

def print_all(c)
  print 'c.chord='
  p      c.chord

  print 'c.highest_pitch_octaveless='
  p      c.highest_pitch_octaveless

  print 'c.lowest_pitch_octaveless='
  p      c.lowest_pitch_octaveless

  print 'c.lilypond='
  p      c.lilypond

  print 'c.bitstring='
  p      c.bitstring
end

CHORAL_RANGE_LOWEST  =  5 # Note F2.
CHORAL_RANGE_HIGHEST = 28 # Note A5.

EXTREME_CHORAL_RANGE = CHORAL_RANGE_LOWEST..CHORAL_RANGE_HIGHEST

MIDDLE_C = 16

SCALE_LENGTH = 7

NAMES = %w[ a b c d e f g ]

SPACE = ' '

OCTAVES = %w[ , ] + [SPACE] + %w[ ' '' ]

ADJUSTMENT_FOR_OCTAVE_BREAKS_AT_C = -2

MAX_SECONDS_COUNT = 2

OKAY_SECONDS_LOWEST = 12

OKAY_SECONDS_HIGHEST = 19

PAIR = 2

MINOR_NINTHS_B_TO_C = [[ 8, 16], [15, 23]]
MINOR_NINTHS_E_TO_F = [[11, 19], [18, 26]]
MINOR_NINTHS = (MINOR_NINTHS_B_TO_C +
                MINOR_NINTHS_E_TO_F).sort

TRITONES_B_TO_F = [          [ 8, 12], [15, 19], [22, 26]]
TRITONES_F_TO_B = [[ 5,  8], [12, 15], [19, 22]          ]
TRITONES = (TRITONES_B_TO_F +
            TRITONES_F_TO_B).sort

MINOR_SECONDS_B_TO_C = [[ 8,  9], [15, 16], [22, 23]]
MINOR_SECONDS_E_TO_F = [[11, 12], [18, 19], [25, 26]]
MINOR_SECONDS = (MINOR_SECONDS_B_TO_C +
                 MINOR_SECONDS_E_TO_F).sort

TWO_CONSECUTIVE_MAJOR_SECONDS_C_TO_E = [              [ 9, 10, 11], [16, 17, 18], [23, 24, 25]]
TWO_CONSECUTIVE_MAJOR_SECONDS_F_TO_A = [[ 5,  6,  7], [12, 13, 14], [19, 20, 21], [26, 27, 28]]
TWO_CONSECUTIVE_MAJOR_SECONDS_G_TO_B = [[ 6,  7,  8], [13, 14, 15], [20, 21, 22]              ]
TWO_CONSECUTIVE_MAJOR_SECONDS = (TWO_CONSECUTIVE_MAJOR_SECONDS_C_TO_E +
                                 TWO_CONSECUTIVE_MAJOR_SECONDS_F_TO_A +
                                 TWO_CONSECUTIVE_MAJOR_SECONDS_G_TO_B).sort

c = Chord.new EXTREME_CHORAL_RANGE.to_a
# print_all c

# halt

COMBINATIONS_OF_SCALE_LENGTH = (EXTREME_CHORAL_RANGE).to_a.combination SCALE_LENGTH

print 'COMBINATIONS_OF_SCALE_LENGTH.count='
p      COMBINATIONS_OF_SCALE_LENGTH.count

has_once = COMBINATIONS_OF_SCALE_LENGTH.map do |combo|
  combo.map{|note| note % SCALE_LENGTH}.uniq.length == SCALE_LENGTH ? combo : nil
end.compact

HAS_EACH_LETTER_ONCE = has_once.map{|a| a.sort} # Sort each chord.

print 'HAS_EACH_LETTER_ONCE.length='
p      HAS_EACH_LETTER_ONCE.length

STARTS_IN_FIRST_OCTAVE = HAS_EACH_LETTER_ONCE.select do |chord|
  chord.first < CHORAL_RANGE_LOWEST + SCALE_LENGTH
end

print 'STARTS_IN_FIRST_OCTAVE.length='
p      STARTS_IN_FIRST_OCTAVE.length

# print 'MINOR_NINTHS='
# p      MINOR_NINTHS

LACKING_TRITONES = exclude STARTS_IN_FIRST_OCTAVE, TRITONES

print 'LACKING_TRITONES.length='
p      LACKING_TRITONES.length

LACKING_MINOR_SECONDS = exclude LACKING_TRITONES, MINOR_SECONDS

print 'LACKING_MINOR_SECONDS.length='
p      LACKING_MINOR_SECONDS.length

LACKING_MINOR_NINTHS = exclude LACKING_MINOR_SECONDS, MINOR_NINTHS

print 'LACKING_MINOR_NINTHS.length='
p      LACKING_MINOR_NINTHS.length

LACKING_TWO_CONSECUTIVE_MAJOR_SECONDS = exclude LACKING_MINOR_NINTHS, TWO_CONSECUTIVE_MAJOR_SECONDS

print 'LACKING_TWO_CONSECUTIVE_MAJOR_SECONDS.length='
p      LACKING_TWO_CONSECUTIVE_MAJOR_SECONDS.length


LACKING_SECONDS_TOO_LOW = LACKING_TWO_CONSECUTIVE_MAJOR_SECONDS.select do |chord|
  exceeding_contained = chord.each_cons(PAIR).map do |pair|
    present = pair.first == pair.last.pred
    exceeds = pair.first < OKAY_SECONDS_LOWEST
    (present && exceeds) ? true : nil
  end.compact
  exceeding_contained.empty?
end

print 'LACKING_SECONDS_TOO_LOW.length='
p      LACKING_SECONDS_TOO_LOW.length

LACKING_SECONDS_TOO_HIGH = LACKING_SECONDS_TOO_LOW.select do |chord|
  exceeding_contained = chord.each_cons(PAIR).map do |pair|
    present = pair.first == pair.last.pred
    exceeds = pair.first > OKAY_SECONDS_HIGHEST
    (present && exceeds) ? true : nil
  end.compact
  exceeding_contained.empty?
end

print 'LACKING_SECONDS_TOO_HIGH.length='
p      LACKING_SECONDS_TOO_HIGH.length

NOT_TOO_MANY_SECONDS = LACKING_SECONDS_TOO_HIGH.select do |chord|
  seconds_contained = chord.each_cons(PAIR).map do |pair|
    present = pair.first == pair.last.pred
    present ? true : nil
  end.compact
  seconds_contained.length <= MAX_SECONDS_COUNT
end

print 'NOT_TOO_MANY_SECONDS.length='
p      NOT_TOO_MANY_SECONDS.length

NO_GAPS_OVER_MIDDLE_C_GREATER_THAN_AN_OCTAVE = NOT_TOO_MANY_SECONDS.select do |chord|
  bad_gaps_contained = chord.each_cons(PAIR).map do |pair|
    exceeds_octave = pair.last - pair.first > SCALE_LENGTH
    under_middle_c = pair.first < MIDDLE_C
    (exceeds_octave && ! under_middle_c) ? true : nil
  end.compact
  bad_gaps_contained.empty?
end

print 'NO_GAPS_OVER_MIDDLE_C_GREATER_THAN_AN_OCTAVE.length='
p      NO_GAPS_OVER_MIDDLE_C_GREATER_THAN_AN_OCTAVE.length

GOOD_CHORDS = NO_GAPS_OVER_MIDDLE_C_GREATER_THAN_AN_OCTAVE.map{|e| Chord.new e}

GOOD_CHORDS_SORTED = GOOD_CHORDS.sort do |a,b|
  by_highest_pitch = a.highest_pitch_octaveless <=> b.highest_pitch_octaveless
  unless 0 == by_highest_pitch
    by_highest_pitch
  else
    b.bitstring <=> a.bitstring
  end
end

GOOD_CHORDS_STRING = GOOD_CHORDS_SORTED.map{|e| e.lilypond}.join ''

s1 = <<'HERE'
\version "2.19.10"
% This file is autogenerated; do not edit it.

note = {
| s1\mp
HERE

s2 = <<'HERE'
}
HERE

s = "#{s1}#{GOOD_CHORDS_STRING}#{s2}"

f = File.open 'out/thirteenthNotes.ily', 'w'
f.print s
