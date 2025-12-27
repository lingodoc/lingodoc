// terms.typ
// Project-specific terms - This file is not tracked in git
//
// Define your project-specific terms here. These terms will be used
// consistently throughout your document across all languages.
//
// NOTE: This file should be customized for your project and not shared in git.
// The terms.typ.example file provides a template.

#let terms = (
  // Bus names
  apollo-3: "Apollo III",
  apollo-2: "Apollo-2-bus",

  // System names
  tempora-3: "Tempora III",
  tempus-3: "Tempus III",

  // Add your project-specific terms below
  // example-term: "Example Value",
)

// Helper function to get a term
// Returns the term if it exists, otherwise returns a warning
#let term(key) = {
  if key in terms {
    terms.at(key)
  } else {
    text(fill: red)[⚠️ UNDEFINED: #key]
  }
}

// Optional: Helper function to get a term with custom formatting
#let term-code(key) = {
  raw(term(key))
}

#let term-bold(key) = {
  strong(term(key))
}

#let term-italic(key) = {
  emph(term(key))
}
