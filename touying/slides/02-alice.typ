// Clock: 0:30–1:45
#import "../theme.typ": *
#import "../components.typ": *

#incident-slide(
  [Checkout Invoicing & Reconciliation],
  [Alice],
  [#text(fill: pal.bad)[OPEN]],
  [The Stringly-Typed Boundary],
  [
    An internal admin tool exports a CSV with a `lineTotal` column (stored in cents).\
    A Node.js import job aggregates those rows to build draft invoices.\
    (In JS "`+`" silently concatenates the string-values without coercing them to a number)
  ],
  [
    #raw(lang: "js", block: true,
      "const amounts = csvRows.map(row => row.lineTotal)\n"
      + "const total   = amounts.reduce((a, b) => a + b)\n"
      + "\n"
      + "// row.lineTotal = \"4500\"  (String, not Number)\n"
      + "// \"4500\" + \"1500\" = \"45001500\"  ← concat, not addition"
    )
    #v(sz(8pt))
    Staged: €450,015.00  ·  Actual: €60.00
  ],
)

#speaker-note[
"Alice's morning starts with a Slack message from accounting. An invoice in the overnight staging batch has a total of €450,015 — about seven and a half thousand times the €60 it should have been. The CSV parser had handed the code values as strings. The aggregation used `+` to sum them, and JavaScript's `+` on two strings is defined — it just concatenates. The job ran clean. The invoice was caught in staging because someone in accounting noticed before the batch went out. The bug isn't stupidity. It's a type system that has no way to express the difference between a string that looks like a number and an actual number."
]
