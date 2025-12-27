// Master Clock Screens - Example Usage
// This chapter demonstrates the master-clock-screenshots template.
//
// The template automatically uses the document's language setting
// from lang.typ, so all labels are translated correctly.

#import "../templates/master-clock-screenshots.typ": *

= Master Clock Control Panels

back to normal

This chapter shows simulated screenshots of the master clock controller interface.
The language is automatically detected from the document settings.



== Main Screen Keys 1-10

This panel configures the first 10 function keys on the main controller screen.
Each key can be assigned to a hammer (striker), swing motor, or other control.

#MainScreenKeys(1,
  "Ham9",    // Key 1: Hammer 9 (Gis0)
  "Ham14",   // Key 2: Hammer 14 (Cis1)
  "Ham15",   // Key 3: Hammer 15 (D1)
  "Ham18",   // Key 4: Hammer 18 (F1)
  "Ham21",   // Key 5: Hammer 21 (Gis1)
  "Ham22",   // Key 6: Hammer 22 (A1)
  "Ham25",   // Key 7: Hammer 25 (C2)
  "Swing1",  // Key 8: Swing motor 1
  "Swing2",  // Key 9: Swing motor 2
  "Swing3",  // Key 10: Swing motor 3
)

#pagebreak()

== Main Screen Keys 11-20

This panel configures function keys 11-20. Some keys are left unused.

#MainScreenKeys(11,
  "Swing4",  // Key 11: Swing motor 4
  "Swing5",  // Key 12: Swing motor 5
  "Swing6",  // Key 13: Swing motor 6
  "Swing7",  // Key 14: Swing motor 7
  "Cont1",   // Key 15: Continuous output 1
  "Cont2",   // Key 16: Continuous output 2
  "Cont3",   // Key 17: Continuous output 3
  "",        // Key 18: Not used
  "",        // Key 19: Not used
  "",        // Key 20: Not used
)

#pagebreak()

== Shorthand Reference

The following shorthand codes are available for button assignments:

#table(
  columns: (auto, auto, auto),
  [*Code*], [*English*], [*Description*],
  [`Ham1`], [Striker 1:C0], [Hammer/striker with calculated note],
  [`Ham13`], [Striker 13:C1], [Note wraps to next octave every 12],
  [`Swing5`], [Swing motor 5], [Swing motor (1-20)],
  [`Cont4`], [Continuous 4], [Continuous output],
  [`""`], [Not used], [Empty/unused slot],
)

== Note Calculation

Hammer numbers are mapped to notes starting from C0:

#table(
  columns: (auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto, auto),
  [*Ham*], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12],
  [*Note*], [C0], [C\#0], [D0], [D\#0], [E0], [F0], [F\#0], [G0], [G\#0], [A0], [A\#0], [B0],
)

Hammers 13-24 are C1 through B1, and so on.
