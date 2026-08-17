// Clock: 0:00–0:30
#import "../theme.typ": *
#import "../components.typ": *

#title-slide(
  [Type-Driven Programming],
  [Correctness by Construction from the Basics to the Cutting Edge],
  [Java Meetup · Inspired Consulting, Köln · 20 Aug 2026],
  [Michael Bauer],
)

#speaker-note[
VERBATIM · budget 0:30 · 62 words.

"Good evening. My name is Michael Bauer, and I have spent about ten years working
as a software and solution architect. Tonight I would like to start with four bugs
from four different teams. They lead into a line of thinking a great deal older than
any of us, which most of you already use without calling it that. Thanks to the
organisers for having me."

The framing deliberately promises the size of the real talk. An earlier draft
opened on a-specific-kind-of-bug, which sets up something much smaller than what
follows; the audience feels that mismatch by minute ten. The bugs are the way in,
not the subject.

Do not say "production incidents". Alice's was caught in staging, and whether any
of the four escaped to production is a matter of process and luck rather than
anything about the bug. Claiming production overstates three of them and is simply
wrong about one.
]
