\version "2.19.10"

#(set-default-paper-size "letter")

% Points; 17.82 is song-book size; 20 for standard parts is default:
#(set-global-staff-size 20)

#(ly:set-option 'point-and-click #f)

\include "out/thirteenthNotes.ily"

printableSole = {
  \new Staff \with {
    \remove "Time_signature_engraver"
  } {
    \clef "bass^8"
    \time 6/1
    \note
    \bar "|."
  }
}

\book {
  \bookOutputName "out/thirteenth"
  \header {
    copyright = ##f
    tagline = \markup {
      \with-url #"http://lilypond.org/web/"
      \tiny \line {
        "All harmonious, pure 13th chords."
        "Copyright &copyright; 2015 Mark D. Blackwell, engraved LilyPond"
        #(lilypond-version)
      }
    }
  }
  \paper {
    ragged-last-bottom = ##f % Prevent too-close systems on last page with ##f.
    top-margin = 5\mm
    bottom-margin = 5\mm % Printer minimum: 5 mm.
    #(include-special-characters) % Copyright symbol.
  }
  \score {
    \printableSole
  }
}
