# sections

This filter partitions a HTML document by adding `<section>` tags around header elements and following content. For example:

    pandoc sample.md --lua-filter=sections.lua

with `sample.md` containing

~~~markdown
# Title

## Subtitle

content
~~~

will result in nested HTML

~~~html
<section>
  <h1 id="title">Title</h1>
  <section>
    <h2 id="subtitle">Subtitle</h2>
    <p>content</p>
  </section>
</section>
~~~
