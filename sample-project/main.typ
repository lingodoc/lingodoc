// main.typ
// Main document file that includes all chapters

// Import language configuration (modified by LingoDoc at compile time)
#import "lang.typ": current-lang

// Import project terms (if exists)
// Copy terms.typ.example to terms.typ and customize for your project
#import "terms.typ": term, terms, term-code, term-bold, term-italic

// Document metadata
#set document(
  title: "Sample LingoDoc Project",
  author: "LingoDoc Team"
)

// Page setup
#set page(
  paper: "a4",
  margin: (x: 2.5cm, y: 2cm),
  numbering: "1",
)

// Text settings
#set text(
  font: "Linux Libertine",
  size: 11pt,
  lang: current-lang,
)

// Heading settings
#set heading(numbering: "1.1")

// Title page
#align(center)[
  #v(1fr)
  #text(24pt, weight: "bold")[Sample LingoDoc Project]
  #v(0.5cm)
  #text(14pt)[Multilingual Document Example]
  #v(1fr)
]

#pagebreak()

// Table of contents
#outline(
  title: if current-lang == "en" [
    Table of Contents
  ] else if current-lang == "es" [
    Tabla de Contenidos
  ] else [
    Table des Matières
  ],
  indent: true,
)

#pagebreak()

// Include chapters
#include "chapters/01-introduction.typ"
#pagebreak()

#include "chapters/02-methodology.typ"
#pagebreak()

#include "chapters/03-user-interface.typ"
#pagebreak()

#include "chapters/04-master-clock-screens.typ"
#pagebreak()

// Add more chapters as needed
