---
lilypond:
  relativize: yes
---

Short appoggiaturas are by no means impracticable in pizzicato. The following
passage from the Scherzo of Beethoven's C-minor Symphony is always executed very
well.

```{.lilypond .ly-fragment ly-name="beethoven" ly-caption="A pizzicato passage from Beethoven's ninth"}
\layout {
    ragged-right = ##t
}

{
    \key c \minor
    \time 3/4
    \tempo "Allegro."
    \relative c'' {
        r4 ees4^"pizz." f4
        f4 f4 g4
        \slashedGrace f8 ees4 d4 c4
        b4 c4 d4
        c4 ees4 f4
        f4 f4 g4
        \slashedGrace f8 ees4 d4 c4 \break
        f4 g4 aes4
        \slashedGrace c,8 b4 a4 g4
        g4 a4 b4
        c4 d4 ees4
        f4 g4 aes4
        aes4 bes4 c4
        c4 c4 b4
        c4 r4 r4 \bar "|."
    }
}
```

Some of our young violinists have learned from Paganini to play rapid descending
scales in pizzicato by plucking the strings with the fingers of the left hand,
which rests firmly on the neck of the violin. They sometimes combine pizzicato
notes (always played with the left hand) with bowed tones, even using the
pizzicato as an accompaniment of a melody played by the bow. All players will
doubtless become familiar with these various techniques in the course of time.
Then composers will be able to take full advantage of them.
