---
title: Track changes in LaTeX and HTML
toc: true
header-includes: |
  ```{=latex}
  \RequirePackage[debrief]{silence}
  \ErrorsOff
  \usepackage{fancyhdr}
  \pagestyle{fancy}
  \fancyhf{}
  \fancyhead[C]{\leftmark}
  ```
...

# Track changes in LaTeX and HTML

A [I agree!]{.comment-start id="1" author="Mathias C. Walter" date="2016-05-21T22:14:00Z"}**simple**[]{.comment-end id="1"} comment from me.

This is a text with [an *exciting*]{.insertion author="MCW" date="2014-06-25T10:40:00Z"} insertion.

This is/was a text with a [*short*]{.deletion author="SWS" date="2014-06-25T10:42:00Z"} deletion.

[Here is the text to be moved.]{.insertion author="FKA" date="2016-04-16T08:20:00Z"}

[Here is the text to be moved.]{.deletion author="John F. Kennedy" date="2016-04-16T08:20:00Z"}

Here is a [Why?]{.comment-start id="2" author="JFK" date="2016-07-29T16:50:00Z"}com[m]{.insertion author="SWS" date="2016-07-29T16:50:00Z"}ent with nest[t]{.deletion author="FKA" date="2016-04-16T08:20:00Z"}ed changes[]{.comment-end id="2"}.

Here is a multi-line paragraph containing some text and a long deletion [short insertion]{.deletion author="MCW" date="2016-04-16T08:20:00Z"} wrapping over two lines.

This is [A comment across paragraphs.]{.comment-start id="4" author="MCW" date="2016-05-09T16:13:00Z"}a new paragraph.

And so[]{.comment-end id="4"} is this.

One [This one has multiple paragraphs. ¶ ¶ See?]{.comment-start id="5" author="Jesse Rosenthal" date="2016-05-09T16:14:00Z"}more[]{.comment-end id="5"}.

# A *header* wi[d]{.deletion author="FKA" date="2018-03-02T23:07:00Z"}th [a]{.insertion author="JFK" date="2018-03-02T23:07:00Z"} [Note]{.comment-start id="3" author="FKA" date="2017-08-24T22:14:00Z"}comment[]{.comment-end id="3"}

Some unmodified text ...

\newpage

... continued from previous page just to test page headers in supporting formats (LaTeX, DOCX, etc.).
