// Clock: 3:00–4:15
#import "../theme.typ": *
#import "../components.typ": *

#incident-slide(
  [Internal Refund-Approval Workflow],
  [Charlie],
  [#text(fill: pal.bad)[OPEN]],
  [The Illegal State Transition],
  [
    Refund lifecycle: Requested → UnderReview → Approved → Executed.
    Only approved refunds may reach the payment processing.
    An operator-tooling shortcut fetches a refund by id and calls `executeRefund`
    without checking the current state. A requested refund posts back to the customer's card.
  ],
  [
    #raw(lang: "java", block: true,
      "void processUrgentRefund(String id) {\n"
      + "  var ref = repo.findById(id);\n"
      + "  paymentRail.execute(ref);\n"
      + "}\n"
      + "\n"
      + "// ref.state never checked\n"
      + "// Requested → Executed, skipping review"
    )
  ],
)

#speaker-note[
"Charlie's team handles the internal refund-approval workflow. Refunds run through Requested, UnderReview, Approved, Executed — only an Approved refund is supposed to reach the payment rail. There's an operator-tooling shortcut for emergencies, and that shortcut fetches a refund by id and calls executeRefund without re-checking the state. A refund still in Requested goes out anyway. Three hours of log archaeology to figure out what happened. The state machine existed in the comments and the wiki and in three developers' heads. It did not exist in the type system. Charlie wasn't reconstructing a bug — he was reconstructing a contract that the language had never enforced."
]
