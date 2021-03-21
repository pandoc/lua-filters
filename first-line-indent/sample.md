---
title: "Sample first line indent"
first-line-indent:
  set-metadata-variable: true # make it false to revert to vertical whitespace separation instead
---

First paragraph. Usually without first-line indent. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec tincidunt lacinia metus id ullamcorper. Integer eget magna quis ipsum lobortis dignissim.

This paragraph should start with a first-line indent. But after this quote:

> Lorem ipsum dolor sit amet, consectetur adipiscing elit.

The paragraph continues, so there should not be a first-line indent.

The quote below ends a paragraph:

> Lorem ipsum dolor sit amet, consectetur adipiscing elit.

\indent This paragraph, then, is genuinely a new paragraph and starts with
a first-line indent.

# Further tests

After a heading (in English typographic style) the paragraph does not have a first-line indent.

In the couple couple of paragraphs that follow the quotes below, we have manually specified `\noindent` and `\indent` respectively. This is to check that the filter doesn't add its own commands to those.

> Lorem ipsum dolor sit amet, consectetur adipiscing elit.

\noindent Manually specified no first line indent.

\indent Manually specified first line ident.

We can also check that indent is removed after lists:

* A bullet
* list

And after code blocks:

```lua
local variable = "value"
```

Or horizontal rules.

---

Last but not least, you can fiddle with the filter options in the document metadata and see what happens.
