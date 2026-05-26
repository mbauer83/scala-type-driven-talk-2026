// Clock: 4:15–5:15
#import "../theme.typ": *
#import "../components.typ": *

#incident-slide(
  [KYC Onboarding Service],
  [Danielle],
  [#text(fill: pal.bad)[OPEN]],
  [The Protocol Drift],
  [
    KYC onboarding service: client uploads documents for compliance review.
    For large payout limits, compliance now requires an extra evidence step.
    Client and server were each correct according to their own contract — the contracts had drifted apart.
    Integration tests covered the common path. The new branch only triggers for large uploads.
  ],
  [
    #raw(lang: "scala", block: true,
      "// client:\n"
      + "client.send(evidenceDocs)\n"
      + "val result = client.receive()  // FinalConfirmation\n"
      + "\n"
      + "// server:\n"
      + "val ev = server.receive()\n"
      + "server.send(EvidenceAccepted)  // ← client never reads this\n"
      + "server.receive()               // FinalConfirmation — client hangs"
    )
  ],
)

#speaker-note[
"Danielle's bug was the hardest to see. The client and server were both correct according to their own contracts. The contracts had drifted apart. The server added a step; the client didn't know. Integration tests covered the common path. The new path only triggered for large payout limits. This ran fine for three weeks before someone tried a large upload."
]
