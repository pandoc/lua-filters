---
title: "short-captions.lua"
lof: true
---

# Short captions in \LaTeX\ output

For latex output, this filter uses the attribute `short-caption` for figures so that the attribute value appears in the List of Figures, if one is desired.

# Usage

Where you would have a figure in, say, markdown as 

    ![The caption](foo.png ) 

You can now specify the figure as 

    ![The long caption](foo.png){short-caption="a short caption"} 

If the document metadata includes `lof:true`,  then the List of Figures will use the short caption. This is particularly useful for students writing dissertations, who often have to include a List of Figures  in the front matter, but where figure captions themselves can be quite lengthy.

    pandoc --lua-filter=short-captions.lua article.md -o article.tex

    pandoc --lua-filter=short-captions.lua article.md -o article.pdf
    


# Example

@Fig:shortcap is an interesting figure with a long caption, but a short caption in the List of Figures.

![This is an *extremely* interesting figure that has a lot of detail I will need to describe in a few sentences. This figure has a short caption that will appear in the list of figures. Other attributes are preserved](images/fig.pdf){#fig:shortcap short-caption="An interesting figure" width="50%"}


# Limitations

- The filter does not currently process the markup within the `short-caption` attribute value.

