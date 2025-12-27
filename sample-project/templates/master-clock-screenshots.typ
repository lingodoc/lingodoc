// Master Clock Screenshots Template
// Consolidated template for generating simulated UI screenshots
// for master clock control panels with multilingual support.
//
// USAGE:
//   #import "../templates/master-clock-screenshots.typ": *
//   #import "../lang.typ": current-lang
//
//   // Keys 1-10 with hammer and swing controls
//   #MainScreenKeys(1, "Ham9", "Ham14", "Ham15", "Ham18", "Ham21", "Ham22", "Ham25", "Swing1", "Swing2", "Swing3")
//
//   // Keys 11-20 with some empty slots
//   #MainScreenKeys(11, "Swing4", "Swing5", "Cont1", "", "", "", "", "", "", "")
//
// SHORTHAND CODES:
//   Ham#     - Hammer/Striker with auto-calculated note (e.g., Ham9 = Striker 9:Gis0)
//   Swing#   - Swing motor 1-20
//   Cont#    - Continuous output
//   ""       - Empty/Not used
//
// LANGUAGE AUTO-DETECTION:
//   The template reads `current-lang` from "../lang.typ" which LingoDoc
//   sets automatically during compilation.

// === LANGUAGE CONFIGURATION ===
// Import current language from project - LingoDoc sets this at compile time
#import "../lang.typ": current-lang

// === COLOR PALETTE ===
// Classic button style with 3D beveled edges
#let ctrl-light-grey = rgb("#c0c0c0")
#let ctrl-white = rgb("#ffffff")
#let ctrl-dark-grey = rgb("#808080")
#let ctrl-black = rgb("#000000")
#let ctrl-navy = rgb("#000080")

// === NOTE NAMES (LANGUAGE-INDEPENDENT) ===
// Using standard scientific pitch notation: C, Cis, D, Dis, E, F, Fis, G, Gis, A, Ais, B
// This system is language-independent and used across all translations

#let note-names = ("C", "Cis", "D", "Dis", "E", "F", "Fis", "G", "Gis", "A", "Ais", "B")

// === TRANSLATIONS ===
#let translations = (
  striker: (
    en: "Striker",
    fr: "Marteau",
    es: "Martillo",
    de: "Hammer",
    nl: "Hamer",
    it: "Martello",
  ),
  swing: (
    en: "Swing motor",
    fr: "Volée",
    es: "Volteo",
    de: "Läuten",
    nl: "Luiden",
    it: "Oscillazione",
  ),
  damper: (
    en: "Damper",
    fr: "Étouffoir",
    es: "Sordina",
    de: "Dämpfer",
    nl: "Demper",
    it: "Sordina",
  ),
  lever: (
    en: "Lever",
    fr: "Levier",
    es: "Palanca",
    de: "Hebel",
    nl: "Hefboom",
    it: "Leva",
  ),
  pedal: (
    en: "Pedal",
    fr: "Pédale",
    es: "Pedal",
    de: "Pedal",
    nl: "Pedaal",
    it: "Pedale",
  ),
  continuous: (
    en: "Continuous",
    fr: "Continu",
    es: "Continuo",
    de: "Kontinuierlich",
    nl: "Continu",
    it: "Continuo",
  ),
  not_used: (
    en: "Not used",
    fr: "Non utilisé",
    es: "No utilizado",
    de: "Nicht verwendet",
    nl: "Niet gebruikt",
    it: "Non utilizzato",
  ),
  main_screen_keys: (
    en: "Main screen keys",
    fr: "Touches écran principal",
    es: "Teclas pantalla principal",
    de: "Hauptbildschirm Tasten",
    nl: "Hoofdscherm toetsen",
    it: "Tasti schermo principale",
  ),
)

// === HELPER FUNCTIONS ===

// Convert hammer number (1-88) to note name with octave
// Notes start from C0: 1=C0, 2=Cis0, ..., 12=B0, 13=C1, etc.
// Note: lang parameter is kept for API compatibility but not used (notes are language-independent)
#let striker-to-note(num, lang: "en") = {
  let note-index = calc.rem(num - 1, 12)
  let octave = calc.floor((num - 1) / 12)
  note-names.at(note-index) + str(octave)
}

// Translate control label based on encoded key name
// Encoded formats: Ham[n], Swing[n], Cont[n], "" or "None"
// Note: Damper, Lever, Pedal are removed as they don't exist in the implementation
#let translate-label(key, lang: "en") = {
  if key == none or key == "" or key == "None" {
    translations.not_used.at(lang, default: translations.not_used.en)
  } else if key.starts-with("Ham") {
    // Extract number more robustly - get everything after "Ham"
    let num-str = key.slice(3)
    let striker-num = int(num-str)
    let trans = translations.striker.at(lang, default: translations.striker.en)
    // Build the label: "Striker 9:Gis0"
    let note = striker-to-note(striker-num, lang: lang)
    trans + " " + num-str + ":" + note
  } else if key.starts-with("Swing") {
    // Extract number more robustly - get everything after "Swing"
    let num-str = key.slice(5)
    let swing-num = int(num-str)
    let trans = translations.swing.at(lang, default: translations.swing.en)
    trans + " " + num-str
  } else if key.starts-with("Cont") {
    // Extract number more robustly - get everything after "Cont"
    let num-str = key.slice(4)
    let cont-num = int(num-str)
    let trans = translations.continuous.at(lang, default: translations.continuous.en)
    trans + " " + num-str
  } else {
    // Return key as-is if no pattern matches
    key
  }
}

// === BASIC WIDGETS ===

// Push button with 3D beveled edge effect
// Buttons collide (no spacing) when placed adjacent
#let PushButton(content, width: 80pt, height: 25pt) = {
  box(
    width: width,
    height: height,
    fill: ctrl-light-grey,
    stroke: (
      top: 2pt + ctrl-white,
      left: 2pt + ctrl-white,
      bottom: 2pt + ctrl-black,
      right: 2pt + ctrl-black,
    ),
    inset: 6pt,
    align(center + horizon, text(size: 10pt, content))
  )
}

// Left button in a glued group (has left stroke, no right stroke)
#let LeftButton(content, width: 80pt, height: 25pt) = {
  box(
    width: width,
    height: height,
    fill: ctrl-light-grey,
    stroke: (
      top: 2pt + ctrl-white,
      left: 2pt + ctrl-white,
      bottom: 2pt + ctrl-black,
      right: none,  // No right stroke to avoid collision line
    ),
    inset: 6pt,
    align(center + horizon, text(size: 10pt, content))
  )
}

// Middle button in a glued group (no left or right strokes)
#let MiddleButton(content, width: 80pt, height: 25pt) = {
  box(
    width: width,
    height: height,
    fill: ctrl-light-grey,
    stroke: (
      top: 2pt + ctrl-white,
      left: none,  // No left stroke to avoid collision line
      bottom: 2pt + ctrl-black,
      right: none,  // No right stroke to avoid collision line
    ),
    inset: 6pt,
    align(center + horizon, text(size: 10pt, content))
  )
}

// Right button in a glued group (has right stroke, no left stroke)
#let RightButton(content, width: 80pt, height: 25pt) = {
  box(
    width: width,
    height: height,
    fill: ctrl-light-grey,
    stroke: (
      top: 2pt + ctrl-white,
      left: none,  // No left stroke to avoid collision line
      bottom: 2pt + ctrl-black,
      right: 2pt + ctrl-black,
    ),
    inset: 6pt,
    align(center + horizon, text(size: 10pt, content))
  )
}

// Text label - right-aligned, bottom-aligned
// Use height parameter to align with adjacent controls
#let TextLabel(content, width: auto, height: auto) = {
  box(
    width: width,
    height: height,
    inset: (x: 4pt, y: 2pt),
    align(right + bottom, text(size: 10pt, content))
  )
}

// Button group - glued buttons in a row (minimal spacing to preserve shadows)
#let ButtonGroup(..buttons) = {
  let btn-list = buttons.pos()
  grid(
    columns: btn-list.len() * (auto,),
    column-gutter: 2pt, // Small gap to preserve bottom-right shadow
    ..btn-list
  )
}

// === SCREENSHOT CANVAS ===

// Main screenshot canvas function
// Creates a window-like container with positioned widgets
#let screenshot(
  width: 640pt,
  height: 480pt,
  widgets: (),
  background: ctrl-light-grey,
  show-grid: false,
  grid-size: 20pt,
) = {
  // Shadow effect
  place(
    dx: 4pt, dy: 4pt,
    box(width: width, height: height, fill: ctrl-dark-grey)
  )

  // Main panel
  box(
    width: width,
    height: height,
    stroke: 2pt + ctrl-black,
  )[
    #box(
      width: 100%,
      height: 100%,
      fill: background,
    )[
      // Debug grid (optional)
      #if show-grid {
        let cols = calc.floor(width / grid-size)
        let rows = calc.floor(height / grid-size)
        for x in range(int(cols) + 1) {
          place(
            line(
              start: (x * grid-size, 0pt),
              end: (x * grid-size, height),
              stroke: 0.5pt + gray.lighten(60%)
            )
          )
        }
        for y in range(int(rows) + 1) {
          place(
            line(
              start: (0pt, y * grid-size),
              end: (width, y * grid-size),
              stroke: 0.5pt + gray.lighten(60%)
            )
          )
        }
      }

      // Place all widgets
      #for widget in widgets {
        place(
          dx: widget.at("x", default: 0pt),
          dy: widget.at("y", default: 0pt),
          widget.content
        )
      }
    ]
  ]
}

// === CONTROL ROW HELPER ===

// Creates a row with label + glued +/center/- buttons
// Layout: odd control numbers on left column, even on right column
// Labels show pairs: 11-12, 13-14, etc. on the same row
#let main-screen-control-row(
  control-num,    // 1-10 (which control in this panel)
  label,          // The translated label text
  start-num: 1,   // Starting display number
) = {
  // Layout constants
  let left-label-x = 0pt
  let left-buttons-x = 65pt
  let right-label-x = 300pt
  let right-buttons-x = 375pt

  let button-width = 44pt
  let center-width = 144pt
  let button-height = 44pt
  let label-width = 63pt
  let right-label-width = 73pt

  // Row y positions: buttons with small gaps to preserve shadows
  // Each row takes button-height + 2pt gap (46pt total) of vertical space
  let row-spacing = button-height + 2pt
  let visual-row = calc.floor((control-num - 1) / 2)
  let y = 50pt + visual-row * row-spacing
  let label-y = y + (button-height / 2)

  // Odd numbers (1,3,5,7,9) go left, even numbers (2,4,6,8,10) go right
  let is-left = calc.rem(control-num, 2) == 1

  let label-x = if is-left { left-label-x } else { right-label-x }
  let buttons-x = if is-left { left-buttons-x } else { right-buttons-x }
  let lbl-width = if is-left { label-width } else { right-label-width }

  // Calculate display number for this control (individual, not pair)
  let display-num = start-num + control-num - 1
  let individual-label = str(display-num) + ":"

  (
    // Row number label showing individual number
    (x: label-x, y: label-y, content: TextLabel(individual-label, width: lbl-width)),
    // Button group: +, label, - (with small gaps to preserve shadows)
    (x: buttons-x, y: y, content: ButtonGroup(
      PushButton("+", width: button-width, height: button-height),
      PushButton(label, width: center-width, height: button-height),
      PushButton("-", width: button-width, height: button-height),
    )),
  )
}

// === MAIN SCREEN KEYS FUNCTION ===

// Generates a complete main screen keys panel with multilingual support.
//
// USAGE:
//   #MainScreenKeys(1, "Ham9", "Ham14", "Ham15", "Ham18", "Ham21", "Ham22", "Ham25", "Swing1", "Swing2", "Swing3")
//   #MainScreenKeys(11, "Swing4", "Swing5", "Cont1", "", "", "", "", "", "", "")
//
// PARAMETERS:
//   start-num: First positional arg - starting key number (1, 11, 21, etc.)
//   ..keys:    Variadic - up to 10 encoded key names (Ham9, Swing1, etc.)
//              Use "" for empty/unused slots
//
// LANGUAGE:
//   Automatically uses `current-lang` from lang.typ
//
#let MainScreenKeys(start-num, ..keys) = {
  // Get keys as array, pad to 10 elements if needed
  let key-list = keys.pos()
  while key-list.len() < 10 {
    key-list.push("")
  }

  // Use auto-detected language
  let lang = current-lang

  // Build title - careful concatenation to avoid extra spaces
  let title-trans = translations.main_screen_keys.at(lang, default: translations.main_screen_keys.en)
  let end-num = start-num + 9
  // Build range string first, then combine
  let range-str = str(start-num) + "-" + str(end-num)
  let title-text = title-trans + " " + range-str

  // Build widgets array
  let widgets = (
    // Title at top center - using content markup to ensure clean spacing
    (x: 0pt, y: 0pt, content: box(
      width: 623pt,
      align(center, text(size: 14pt)[#title-trans #range-str])
    )),
  )

  // Add all 10 control rows
  for i in range(10) {
    let label = translate-label(key-list.at(i), lang: lang)
    widgets += main-screen-control-row(i + 1, label, start-num: start-num)
  }

  // Scale the screenshot to fit approximately 2/3 of A4 page width
  // A4 with 2.5cm margins = ~160mm usable = ~453pt
  // 2/3 of page width = ~302pt, but using 50% for better text rendering
  // At 50%, 623pt becomes 311pt (close enough), and 14pt text becomes 7pt (readable)
  // At 48.5%, text was only 6.8pt causing rendering artifacts
  // Height increased to 310pt to account for 2pt gaps between 5 button rows
  scale(
    x: 50%,
    y: 50%,
    screenshot(
      width: 623pt,
      height: 310pt,
      background: white,
      widgets: widgets
    )
  )
}

// === GRID-BASED POSITIONING (25x13 grid) ===

// Grid configuration for full-page layouts
#let grid-cols = 25
#let grid-rows = 13
#let page-width = 170mm
#let page-height = 257mm
#let cell-width = page-width / grid-cols
#let cell-height = page-height / grid-rows

// Convert grid coordinates to absolute position
#let grid-pos(x, y) = (
  x: x * cell-width,
  y: y * cell-height
)

// Grid-based button
#let grid-button(content, x, y, w: 2, h: 2) = {
  let pos = grid-pos(x, y)
  place(
    dx: pos.x,
    dy: pos.y,
    PushButton(content, width: w * cell-width, height: h * cell-height * 0.9)
  )
}

// Grid-based label (bottom aligned)
#let grid-label(content, x, y, w: 1) = {
  let pos = grid-pos(x, y)
  place(
    dx: pos.x,
    dy: pos.y,
    TextLabel(content, width: w * cell-width, height: cell-height)
  )
}

// Input field with 3D inset effect
#let InputField(content, width: 180pt, height: 22pt) = {
  box(
    width: width,
    height: height,
    fill: white,
    stroke: (
      top: 1.5pt + ctrl-black,
      left: 1.5pt + ctrl-black,
      bottom: 1.5pt + ctrl-white,
      right: 1.5pt + ctrl-white,
    ),
    inset: 4pt,
    align(left + horizon, text(size: 10pt, content))
  )
}

// Grid-based edit field
#let grid-edit(content, x, y, w: 4) = {
  let pos = grid-pos(x, y)
  place(
    dx: pos.x,
    dy: pos.y,
    InputField(content, width: w * cell-width, height: cell-height * 0.85)
  )
}

// Grid-based double-line label (top aligned)
#let grid-label-double(line1, line2, x, y, w: 1) = {
  let pos = grid-pos(x, y)
  place(
    dx: pos.x,
    dy: pos.y,
    box(
      width: w * cell-width,
      height: cell-height,
      align(left + top, text(size: 10pt)[
        #line1 \
        #line2
      ])
    )
  )
}

// === CONVENIENCE ALIASES ===
// Short names for grid-based components
#let button = grid-button
#let label = grid-label
#let label-double = grid-label-double
#let edit = grid-edit
