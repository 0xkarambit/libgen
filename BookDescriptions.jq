def serial(field):
  if has(field)
    then "\(field) : \(.[field])"
  else empty
  end;

[.[1:][]
| .children
| { id: .[0].text,
    # There can be multiple author (and hence multiple child elements of this <td>)
    author: [.[1].children[] | .text] | join(", "),
    title: [.[2].children[] | .text] | join(""),
    # There can be multiple <a> tags with different links (like for searching a series of books)
    # But we only need the link to download the book
    link: (.[2].children[]
      | .href? | if . != null and test("book/index.php") then . else empty end),
    publisher: .[3].text,
    year: .[4].text,
    pages: .[5].text,
    language: .[6].text,
    size: .[7].text,
    extension: .[8].text
  }
|
  [
    "title : " + .title,
    "author : " + .author,
    "id : " + .id,
    serial("publisher"),
    serial("year"),
    serial("pages"),
    serial("language"),
    serial("size"),
    serial("link"),
    serial("extension")
  ] | join("\n") 
] | @sh