#!/usr/bin/env python3
"""
prose-lint.py — reject LLM-tell prose in speaker notes.

Scope: the text a human will actually say. By convention that is the double-
quoted spans inside a slide's `#speaker-note[...]` block; everything else in a
note is delivery guidance and is not linted.

The target register is varied, natural sentence rhythm with real subordination.
That cuts both ways: the cadence tricks below read as machine-written, and so
does their opposite — a flat run of short declaratives. Both are flagged.

Note on sentence length: a very long sentence is a *delivery* risk for a talk
given in a second language, so it warns. It is not an error, because forcing
everything short produces exactly the staccato monotone this file exists to
prevent.

Usage:
    python3 tools/prose-lint.py touying/slides/02-alice.typ ...
    python3 tools/prose-lint.py --all
    python3 tools/prose-lint.py --hook        # reads Claude Code hook JSON on stdin

Exit codes: 0 clean (warnings allowed), 2 one or more errors.
"""

import argparse
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SLIDE_GLOB = os.path.join(ROOT, "touying", "slides", "*.typ")

LONG_SENTENCE_WORDS = 35    # delivery risk — warns, never blocks
MAX_EMDASH_PER_100 = 2.5
MONOTONE_RUN = 4            # consecutive same-band sentences that read as flat
MONOTONE_BAND = (4, 15)     # the "punchy short declarative" band
MIN_LENGTH_VARIATION = 0.38 # stdev/mean below this over a whole note is flat


_QUOTE_PARITY = []


# ── extraction ───────────────────────────────────────────────────────────────

def _resolve_reads(note, slide_path):
    """Inline any #read("...") the note delegates to, so tools see real prose."""
    def sub(m):
        rel = m.group(1)
        target = os.path.normpath(os.path.join(os.path.dirname(slide_path), rel))
        try:
            return open(target, encoding="utf-8").read()
        except OSError:
            return ""
    return re.sub(r'#read\(\s*"([^"]+)"\s*\)', sub, note)


def spoken_text(src, slide_path=None):
    """The double-quoted spans inside #speaker-note[...]; '' if none."""
    i = src.find("#speaker-note[")
    if i < 0:
        _QUOTE_PARITY.append(0)   # keep the list aligned; otherwise check()
        return ""                 # reads the PREVIOUS file's parity
    j = src.index("[", i)
    depth = 0
    for k in range(j, len(src)):
        if src[k] == "[":
            depth += 1
        elif src[k] == "]":
            depth -= 1
            if depth == 0:
                break
    note = _resolve_reads(src[j + 1:k], slide_path or '')
    note = re.sub(r"^\s*(→|//).*$", "", note, flags=re.M)
    _QUOTE_PARITY.append(note.count('"') % 2)
    return " ".join(re.findall(r'"([^"]*)"', note, flags=re.S))


def sentences(text):
    text = re.sub(r"\s+", " ", text).strip()
    parts = re.split(r"(?<=[.!?])\s+", text)
    return [p.strip() for p in parts if p.strip()]


def words(s):
    return re.findall(r"[A-Za-z0-9'’\-]+", s)


# ── rules ────────────────────────────────────────────────────────────────────
# Each rule yields (severity, rule_id, excerpt, explanation).

PADDING = [
    "in order to", "the fact that", "at the end of the day", "when it comes to",
    "it is important to note", "it's worth noting", "needless to say",
    "simply put", "to be honest", "quite frankly", "at its core", "in essence",
    "it turns out that", "the reality is", "more often than not",
]

AI_DICTION = [
    "delve", "tapestry", "testament to", "landscape of", "realm of", "pivotal",
    "leverage", "seamless", "underscore", "showcase", "foster", "harness",
    "unlock", "elevate", "game-changer", "deep dive", "here's the thing",
    "the beauty of", "moreover", "furthermore", "crucially", "notably",
    "it's worth remembering", "let that sink in",
]

NOT_X_BUT_Y = [
    (r"\bnot (just|only|merely|simply)\b[^.?!]{0,70}\bbut\b", "not-just-X-but-Y"),
    (r"\bit'?s not\b[^.?!]{0,60}[—–]\s*it'?s\b", "it's-not-X—it's-Y"),
    (r"\bisn'?t\b[^.?!]{0,60}[—–]\s*it'?s\b", "isn't-X—it's-Y"),
    (r"\bnot\b[^.?!]{0,50}\bbut rather\b", "not-X-but-rather-Y"),
    (r"\bthat'?s not\b[^.?!]{0,40}[.—–]\s*that'?s\b", "that's-not-X.-that's-Y"),
]

# Shapes MB flagged in the 18 Aug review. None of these were catchable by the
# rules above, and all four were produced by me in one pass, which is the point:
# the linter encodes faults it has SEEN, so every new fault has to be added the
# day it is found or it recurs.
#
#   "one question, taken up in four places — none of them finished with it"
#   "None of this is if (a && b) — a boolean is computed while the program runs"
#   "the signature is the claim, the body is what makes good on it"
#   "Four notations, and I am deliberately not going to teach them"

NEGATIVE_DEFINITION = [
    (r"\bnone of (this|that|these|it) (is|are|was|were)\b", "none-of-this-is-X"),
    (r"\b(is|are|was|were) neither\b", "X-is-neither"),
    (r"^(that|this|it|these|those)'?s? (is |are )?not\b", "leading 'that is not…'"),
    (r"\bnothing (here|on this slide|about this) is\b", "nothing-here-is-X"),
]

# Talking about the talk instead of giving the talk. A slide that announces what
# it will not do has spent a line saying nothing.
META_COMMENTARY = [
    (r"\bi (am|'m)( deliberately| not going| going)\b[^.?!]{0,40}\bnot\b", "I-am-not-going-to"),
    (r"\b(deliberately|purposely) not (going to |about to )?(teach|explain|cover|show)\b",
     "announcing what the slide will not do"),
    (r"\bwhat i want (to do |to show )?here\b", "what-I-want-to-do-here"),
    (r"\bthat is (the|my) (whole )?(point|map|idea) (of|for|here)\b", "that-is-the-point-of"),
    (r"\b(the|this) (slide|beat|section) (is|does|exists)\b", "the slide talking about itself"),
]

# Balanced apposition with no content in either half. Reads like an insight and
# carries none: "the X is the A, the Y is the B."
APHORISM = [
    (r"\bthe \w+ is the \w+,? and the \w+ is\b", "the-X-is-the-Y-and-the-Z-is-the-W"),
    (r"\bis what makes good on (it|that)\b", "makes-good-on-it"),
    (r"\bnone of them (finished|ever finished|got there)\b", "trailing summary clause"),
    (r"\bthat is not a metaphor\b", "that-is-not-a-metaphor"),
]

KICKERS = [
    (r"\byou just don'?t call it that\b", "stock kicker"),
    (r"\bwhich is exactly\b", "which-is-exactly"),
    (r"^and that'?s (the|what|why|how)\b", "and-that's-the-… kicker"),
    (r"\bwelcome to\b", "welcome-to- kicker"),
]

SUPERLATIVES = [
    r"\bthe (hardest|worst|best|single biggest|most important|most interesting)\b",
    r"\bthe most \w+ (thing|part|bug|idea)\b",
]

# Overclaims. Every one of these was actually made and had to be retracted during
# review. The pattern: reaching for a stronger contrast than the facts carry, which
# makes the argument WEAKER because the audience immediately supplies the
# counterexample. Errors are the ones already corrected once; warnings are the
# shapes that tend to slide the same way.
OVERCLAIM_ERRORS = [
    (r"\bproduction (incident|bug|failure)s?\b",
     "Only some of the four bugs escaped to production, and Alice's did not. "
     "Whether a bug reaches production is process and luck, not a property of "
     "the bug — and the weaker claim is the stronger argument."),
    (r"\b(more |additional |no amount of )?test(s| coverage)? would not have\b",
     "A test could have caught every one of these. The defensible claim is about "
     "the kind of guarantee, not the possibility."),
    (r"\bno (test|amount of testing) (would|could)\b",
     "Same overclaim. Concede that a test could catch it, then draw the "
     "distinction that survives."),
    (r"\bjava cannot (express|state|do)\b",
     "Java can express more than it looks like, via phantom generics and "
     "GADT-style witness encodings. Narrow the claim: it cannot derive a type "
     "index from a runtime value without hand-rolled encoding, carry a predicate "
     "in a type, or compute types from types."),
]

OVERCLAIM_WARNINGS = [
    (r"\bimpossible to (write|express|construct)\b",
     "Prefer the precise form: the state is unrepresentable in the type system. "
     "'Impossible' invites a counterexample you did not mean to claim against."),
    (r"\bnever (fails|breaks|happens|goes wrong)\b", "Absolute. Is it true?"),
    (r"\ball you (need|have to do)\b", "Understates the cost. S29 exists to be honest about it."),
    (r"\bguarantee[sd]? that\b", "Check the guarantee is the one the calculus actually gives."),
]

# Terms this audience does not uniformly share. Not banned — glossed, or replaced.
JARGON = [
    "kyc", "psd2", "sca", "liability shift", "catamorphism", "involution",
    "ι-reduction", "iota-reduction", "definitional equality", "hylomorphism",
    "anamorphism", "profunctor", "bifunctor", "existential quantification",
]


def check(text, path, rhythm=True):
    out = []
    if _QUOTE_PARITY and _QUOTE_PARITY[-1]:
        out.append(("error", "unbalanced-quotes", "odd number of \" in this note",
                    "Spoken text is delimited by double quotes. An odd count silently "
                    "swaps which half is treated as speech — the counter and the linter "
                    "then measure your commentary and ignore your script."))
    sents = sentences(text)
    low = text.lower()

    # 1. not-X-but-Y and its variants
    for pat, name in NOT_X_BUT_Y:
        for m in re.finditer(pat, low, flags=re.I | re.M):
            out.append(("error", "negative-contrast", text[m.start():m.end()],
                        f"'{name}' as a sentence shape. State the thing directly."))

    # Rhythm rules need continuous prose. A bullets-plus-fragments note is a set
    # of disconnected phrases, where "four short sentences in a row" means
    # nothing — so those rules are skipped and the claim rules still apply.
    if not rhythm:
        for pat, why in OVERCLAIM_ERRORS:
            for m in re.finditer(pat, low):
                out.append(("error", "overclaim", text[m.start():m.end()], why))
        for term in JARGON:
            for m in re.finditer(rf"\b{re.escape(term)}\b", low):
                out.append(("warn", "jargon", text[m.start():m.end()],
                            "Gloss it, or use a term the talk established."))
        return out

    # 2. tricolon — three or more consecutive short sentences used for rhythm
    run = 0
    for s in sents:
        if len(words(s)) <= 6:
            run += 1
            if run == 3:
                out.append(("error", "tricolon", s,
                            "Three consecutive short sentences read as cadence, "
                            "not argument. Join them or cut one."))
        else:
            run = 0

    # 3. fragment-climax — a very short sentence dropped after a long one
    hits = 0
    for a, b in zip(sents, sents[1:]):
        if len(words(a)) >= 8 and len(words(b)) <= 3:
            hits += 1
            if hits >= 2:
                out.append(("error", "fragment-climax", f"… {a} {b}",
                            "Long sentence followed by a one-or-two-word "
                            "punch, more than once. This is a build-up tic."))
                break

    # 4. anaphora — same opening repeated across consecutive sentences
    for i in range(len(sents) - 2):
        heads = [" ".join(words(s)[:2]).lower() for s in sents[i:i + 3]]
        if len(set(heads)) == 1 and heads[0]:
            out.append(("error", "anaphora", " / ".join(sents[i:i + 3]),
                        f"Three sentences opening '{heads[0]}…'. "
                        "Rhythm device; vary or merge."))
            break

    # 5. padding and filler
    for p in PADDING:
        if p in low:
            out.append(("error", "padding", p, "Pleonasm. Delete it."))

    # 6. rhetorical question answered immediately
    for m in re.finditer(r"\?\s+(Because|It means|The answer|Simply|Well,)", text):
        out.append(("error", "rhetorical-qa", text[max(0, m.start() - 40):m.end()],
                    "Rhetorical question followed by its own answer."))

    # 6b. shapes from the 18 Aug review — see the block above the tables
    for pat, name in NEGATIVE_DEFINITION:
        for m in re.finditer(pat, low, flags=re.I | re.M):
            out.append(("error", "negative-definition", text[m.start():m.end()],
                        f"'{name}'. Say what the thing IS. Defining by exclusion "
                        "makes the audience hold the wrong idea in mind while you "
                        "deny it, and it is the shape of a disclaimer, not a claim."))
    for pat, name in META_COMMENTARY:
        for m in re.finditer(pat, low, flags=re.I | re.M):
            out.append(("error", "meta-commentary", text[m.start():m.end()],
                        f"'{name}'. The talk should not narrate itself. Cut it and "
                        "the information is unchanged."))
    for pat, name in APHORISM:
        for m in re.finditer(pat, low, flags=re.I | re.M):
            out.append(("error", "aphorism", text[m.start():m.end()],
                        f"'{name}'. Balanced clauses with no content in either half. "
                        "Delete it and check what was lost; usually nothing."))

    # 7. stock kickers
    for pat, name in KICKERS:
        for s in sents:
            if re.search(pat, s.strip(), flags=re.I):
                out.append(("error", "kicker", s, f"'{name}'."))

    # 8. monotone — a flat run of short declaratives is its own LLM tell,
    #    and it is what you get if you "fix" prose by shortening everything.
    lo, hi = MONOTONE_BAND
    run, start = 0, 0
    for i, s in enumerate(sents):
        if lo <= len(words(s)) <= hi:
            if run == 0:
                start = i
            run += 1
            if run == MONOTONE_RUN:
                out.append(("error", "monotone", " ".join(sents[start:i + 1]),
                            f"{MONOTONE_RUN} consecutive sentences of {lo}–{hi} "
                            "words. Flat staccato. Subordinate a clause, or join two."))
                run = 0
        else:
            run = 0

    lens = [len(words(s)) for s in sents]
    if len(lens) >= 6:
        mean = sum(lens) / len(lens)
        var = sum((n - mean) ** 2 for n in lens) / len(lens)
        if mean > 0 and (var ** 0.5) / mean < MIN_LENGTH_VARIATION:
            out.append(("error", "monotone-overall",
                        f"{len(lens)} sentences, mean {mean:.0f} words, "
                        f"variation {(var ** 0.5) / mean:.2f}",
                        "Sentence lengths barely vary across the note. Real speech "
                        "mixes long and short."))

    # 9. very long sentences — delivery risk only, never blocking
    for s in sents:
        n = len(words(s))
        if n > LONG_SENTENCE_WORDS:
            out.append(("warn", "long-sentence", s,
                        f"{n} words. Hard to deliver in one breath — consider "
                        "splitting, but do not shorten everything."))

    # 9. AI diction (warning — some of these are legitimate words)
    for w in AI_DICTION:
        if re.search(rf"\b{re.escape(w)}\b", low):
            out.append(("warn", "ai-diction", w, "Overused register. Prefer plainer."))

    # 10. em-dash density
    n_words = max(1, len(words(text)))
    dashes = len(re.findall(r"[—–]", text))
    if dashes / n_words * 100 > MAX_EMDASH_PER_100:
        out.append(("warn", "em-dash-density",
                    f"{dashes} dashes / {n_words} words",
                    "Dashes used as drama. Most should be full stops."))

    # 11. unearned superlatives
    for pat in SUPERLATIVES:
        for m in re.finditer(pat, low):
            out.append(("warn", "superlative", text[m.start():m.end()],
                        "Ranking claim the audience cannot check."))

    # 12. overclaims — the recurring failure mode, each already retracted once
    for pat, why in OVERCLAIM_ERRORS:
        for m in re.finditer(pat, low):
            out.append(("error", "overclaim", text[m.start():m.end()], why))
    for pat, why in OVERCLAIM_WARNINGS:
        for m in re.finditer(pat, low):
            out.append(("warn", "overclaim", text[m.start():m.end()], why))

    # 13. jargon this room does not uniformly share
    for term in JARGON:
        for m in re.finditer(rf"\b{re.escape(term)}\b", low):
            out.append(("warn", "jargon", text[m.start():m.end()],
                        "Gloss it in the same breath, or use a term from the "
                        "payment domain the talk already established."))

    return out


# ── driver ───────────────────────────────────────────────────────────────────

# A headline names a concept. It is a label on a section of the argument, not a
# line of speech — "You have already seen a quantifier" is something you say, and
# putting it in 60pt type spends the largest text on the slide on nothing the
# audience can carry away. Openings that give it away:
TITLE_OPENERS = re.compile(
    r"^\s*(you|we|i|let'?s|here'?s|now|so|and|but|it'?s|there'?s|perhaps|"
    r"why not|remember)\b", re.I)


def slide_title(src):
    """The h2 a slide-class function is called with — the first bracketed
    argument on its own line after the `eyebrow:` line. Every slide in this
    deck is written that way; a slide that is not simply returns None."""
    m = re.search(r"eyebrow:[^\n]*\n\s*\[([^\]\n]{3,90})\],", src)
    return m.group(1).strip() if m else None


def check_title(src, path):
    title = slide_title(src)
    if not title:
        return []
    if TITLE_OPENERS.match(title):
        return [("error", "title-is-a-sentence", title,
                 "A headline names a concept; this one is a line of speech. "
                 "It is the biggest text on the slide and should be the part "
                 "an audience could write down.")]
    return []


def lint_file(path):
    try:
        src = open(path, encoding="utf-8").read()
    except OSError:
        return []
    findings = []
    if path.endswith(".typ"):
        findings += [(sev, rid, exc, why, path)
                     for sev, rid, exc, why in check_title(src, path)]
    if path.endswith(".md"):
        # Script files are the note body; wrap so one extractor serves both.
        src = "#speaker-note[" + src + "]"
    rhythm = "EST-WORDS:" not in src or "WORKED VERBATIM" in src
    text = spoken_text(src, path)
    unbalanced = bool(_QUOTE_PARITY and _QUOTE_PARITY[-1])
    if len(words(text)) < 15 and not unbalanced:
        return findings
    return findings + [(sev, rid, exc, why, path)
                       for sev, rid, exc, why in check(text, path, rhythm=rhythm)]


def report(findings):
    if not findings:
        return 0
    errors = [f for f in findings if f[0] == "error"]
    by_file = {}
    for f in findings:
        by_file.setdefault(f[4], []).append(f)
    lines = []
    for path, fs in by_file.items():
        lines.append(f"\n{os.path.relpath(path, ROOT)}")
        for sev, rid, exc, why, _ in fs:
            tag = "ERROR" if sev == "error" else "warn "
            exc = re.sub(r"\s+", " ", exc).strip()
            if len(exc) > 96:
                exc = exc[:93] + "…"
            lines.append(f"  {tag} [{rid}]  {exc}")
            lines.append(f"        → {why}")
    lines.append("")
    lines.append("Target: varied rhythm, real subordination, claims that are true. "
                 "No tricolons, no not-X-but-Y, no fragment build-ups, no padding — "
                 "and no flat run of short declaratives either.")
    sys.stderr.write("\n".join(lines) + "\n")
    return 2 if errors else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="*")
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--hook", action="store_true",
                    help="read Claude Code hook JSON from stdin")
    args = ap.parse_args()

    if args.hook:
        try:
            payload = json.load(sys.stdin)
        except Exception:
            return 0
        path = (payload.get("tool_input") or {}).get("file_path")
        if not path:
            return 0
        # The scripts are the source of truth (touying/scripts/README.md); an
        # earlier matcher accepted only .typ under touying/slides, so the hook
        # was silently dead on exactly the files it was built to guard.
        in_slides = path.endswith(".typ") and os.path.join("touying", "slides") in path
        in_scripts = path.endswith(".md") and os.path.join("touying", "scripts") in path
        # scripts/README.md documents the banned constructions by quoting them,
        # so it trips every claim rule it describes and can never pass. It is
        # documentation, not a spoken script, and nothing in the deck reads it.
        if os.path.basename(path).lower() == "readme.md":
            return 0
        if not (in_slides or in_scripts):
            return 0
        return report(lint_file(path))

    paths = sorted(glob.glob(SLIDE_GLOB)) if args.all else args.files
    findings = []
    for p in paths:
        findings.extend(lint_file(p))
    return report(findings)


if __name__ == "__main__":
    sys.exit(main())
