# scrlttr2

This filter allows to write DIN 5008 letter using the [scrlttr2]
LaTeX document class from KOMA script. It converts metadata to
the appropriate KOMA variables and allows using the default LaTeX
template shipped with pandoc.

[scrlttr2]: https://www.ctan.org/pkg/scrlttr2

## Base variables

  - `opening`: phrase used as an opening;
    defaults to "Dear Sir/Madam,"
  - `closing`: closing phrase; defaults to "Sincerely,"
  - `address`: recipient's street address;
    defaults to "no address given"
  - `date`: the date of the letter; defaults to the current day.

## KOMA Variables

Currently, the following metadata fields are translated to KOMA
variables:

- `fromaddress` (alias: `return-address`): address of the sender
- `fromfax` (alias: `fax`): sender's fax number
- `fromemail` (alias: `email`): sender's email
- `fromlogo` (alias: `logo`): image to be used as the sender's logo
- `fromname` (alias: `author`): sender name
- `fromphone` (alias: `phone`): sender's phone number
- `fromurl` (alias: `url`): sender's URL
- `customer`: customer number
- `invoice`: invoice number
- `myref`: sender's reference
- `place`: sender's place used near date
- `signature`: sender's signature
- `subject`: letter's subject
- `title`: letter title
- `yourref`: addressee's reference

The values of these variables are converted to MetaInlines. If a
list is given, then each list item is used as a line, e.g.,

    fromaddress:
      - 35 Industry Way
      - Springfield
      
The `KOMAoptions` value is inferred from the given variables, but
can be overwritten by specifying it explicitly.

See the scrlttr2 documentation for details.

## Intended Usage

Many sender variables don't change, so it is sensible to provide
default values for these. Authors using Markdown to draft letters
can use a separate YAML file for this. E.g., if there is a file
`default.yml` which contains the sender's details, then only the
addressee's data must be specified.

    pandoc --lua-filter=scrlttr2 letter.md default.yml -o out.pdf
