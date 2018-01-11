# task-list

Github, as well as some other sites, support a Markdown extension
to create task lists. Adding `[ ]` at the beginning of a bullet
list marks the items as an open todo, while `[x]` marks it as
done:

    - [x] Find the Higgs.
    - [ ] Create a unified theory for everything.
 
This filter recognizes this syntax and converts the ballot boxes
into a representation suitable for the chosen output format.
Ballot boxes are rendered as

-   checkbox input elements in HTML,
-   ASCII boxes in gfm and org-mode, and
-   ballot box UTF-8 characters otherwise.
