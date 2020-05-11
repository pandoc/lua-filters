---
lilypond:
  relativize: yes
---

# The Oboe
This instrument has a range of two octaves and fifth and is written in the
G-clef:

```{.lilypond .ly-fragment ly-caption="The range of the oboe" ly-name="oboe"}
\relative c' {
    \override Staff.TimeSignature #'stencil = ##f
    \cadenzaOn
    b4 c4 d4 e4 f4 g4 a4 b4 c4 d4 e4 f4 g4 a4 b4 c4 d4 e4 f4 \bar "|."
    \cadenzaOff
}
```

The two highest notes should be used with caution; the F in particular is risky
when it enters abruptly. Some oboes have the low B♭ `\new Staff { \override
Staff.TimeSignature #'stencil = ##f \cadenzaOn bes4 \cadenzaOff }`{.lilypond
ly-caption="A low note" ly-name="b-flat"}; but this tone, not generally
available on this instrument, should better be avoided.
