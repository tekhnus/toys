req
{{std
  "std"}
 {eq
  "std"
  eq}
 {decons-pat
  "std"
  decons-pat}
 {head
  "std"
  head}
 {concat-bytestrings
  "std"
  concat-bytestrings}
 {panic
  "std"
  panic}}

defn fntestx (body expect)
{return {list {'brackets 'defn 'calltest '() body 'val '= '(calltest) 'if {list {'/std/eq 'val expect}} '{panics = panics} {list {'brackets 'panics '= {list {'/std/cons {list {'/std/concat-bytestrings '(/std/concat-bytestrings (/std/repr val) " != ") {list {'/std/repr expect}}}} 'panics}}}}}}}

export
{(fntestx fntestx)}
