# Manim Video Plan — Type-Driven Programming (3Blue1Brown-style)

> **Goal**: Produce a 45-minute talk video in a 3Blue1Brown aesthetic — dark background,
> amber/gold accent, mathematical precision in the animated sequences — interspersed
> with high-fidelity slide content for the narrative beats that need no animation.
>
> **Strategy**: Hybrid production. The touying PDF is exported as slide screenshots
> (`ImageMobject`). Simple slides play as `FadeIn(slide_png)`. The ~8 animation
> sequences are built natively in Manim (Community Edition, Python) and cut in via a
> beat-driven timing file. A single `beats.yaml` file lets you retime every individual
> animation beat against the recorded audio without touching Python code.

---

## 1. Talk Structure Reference

| #   | File                 | Clock      | Title                                    | Treatment         |
|-----|----------------------|------------|------------------------------------------|-------------------|
| S1  | 01-title             | 0:00–0:30  | Title card                               | Fade-in           |
| S2  | 02-alice             | 0:30–1:45  | Alice — Stringly-Typed Boundary          | Code-reveal anim  |
| S3  | 03-bob               | 1:45–3:00  | Bob — Forgotten Branch                   | Code-reveal anim  |
| S4  | 04-charlie           | 3:00–4:15  | Charlie — Illegal State Transition       | Code-reveal anim  |
| S5  | 05-danielle          | 4:15–5:15  | Danielle — Protocol Drift                | Code-reveal anim  |
| S6  | 06-pattern           | 5:15–5:30  | The Pattern                              | Sequential reveal |
| S7  | 07-toolkit           | 5:30–7:00  | Toolkit — 2500-year thread               | Beat-grid reveal  |
| S8  | 08-crisis            | 7:00–8:30  | The Crisis and the Fix                   | Quadrant reveal   |
| S9  | 09-convergence1      | 8:30–9:05  | Convergence — Church/Turing + Gentzen    | Beat-grid reveal  |
| S10 | 10-gentzen-or        | ~9:05–9:35 | Gentzen: Logic as Interface              | **★ MANIM A**     |
| S11 | 11-convergence2      | 9:35–10:05 | Convergence — + Curry-Howard             | Beat-grid reveal  |
| S12 | curry-howard         | ~9:35–10:05| Curry-Howard Correspondence              | **★ MANIM B**     |
| S13 | 12-mltt              | ~10:05–10:20| MLTT: Π and Σ Types                     | **★ MANIM C**     |
| S14 | 13-convergence3      | 10:20–10:45| Convergence — + Coquand                  | Beat-grid reveal  |
| S15 | 14-lambda-cube       | 10:45–11:30| The Lambda Cube                          | **★ MANIM D**     |
| S16 | 15-test-spine        | 11:30–12:00| Payment process flow                     | Slide fade-in     |
| S17 | 16-stage0            | 12:00–13:00| Stage 0 — JS, untyped baseline           | Stage-card anim   |
| S18 | 17-stage1            | 13:00–17:00| Stage 1 — Simple types                  | Code fade-in      |
| S19 | 18-stage2            | (est.)     | Stage 2 — Generics                      | Code fade-in      |
| S20 | 19-stage3            | (est.)     | Stage 3 — Function types + sum types    | Code fade-in      |
| S21 | 20-stage3-payoff     | (est.)     | Stage 3 payoff                          | Shield pop anim   |
| S22 | 21-bridge            | 19:30–21:00| Bridge: Records → Typestate             | Fade-in           |
| S23 | 22-stage4            | (est.)     | Stage 4 — Phantom typestate (Scala/Java)| Code fade-in      |
| S24 | 23-stage4-payoff     | (est.)     | Stage 4 payoff                          | Shield pop anim   |
| S25 | 24-java-ceiling      | 25:00–26:00| The Java Ceiling                        | Fade-in           |
| S26 | 25-stage5            | (est.)     | Stage 5 — Scala 3 refinement/session    | Code fade-in      |
| S27 | 26-session-types     | 30:00–30:45| Session Types                           | **★ MANIM F**     |
| S28 | stage5-mechanisms    | (est.)     | Stage 5: Mechanisms reference           | Fade-in           |
| S29 | 27-stage5-payoff     | (est.)     | Stage 5 payoff                          | Shield pop anim   |
| S30 | scala3-ceiling       | (est.)     | The Scala 3 Ceiling                     | Fade-in           |
| S31 | 28-stage6-bridge     | 35:00–35:30| Stage 6 — Idris 2 bridge                | Stage-card anim   |
| S32 | 29-mltt-running      | 35:30–36:00| MLTT Rules Running as Programs          | Dual-panel reveal |
| S33 | 30-stage6-payoff     | (est.)     | Stage 6 payoff                          | Shield pop anim   |
| S34 | 31-the-climb         | 41:00–42:00| The Climb — summary table               | **★ MANIM G**     |
| S35 | 32-agentic           | 42:00–43:00| Agentic Development                     | Fade-in           |
| S36 | 33-horizon           | 43:00–43:30| Further Horizon                         | Fade-in           |
| S37 | where-to-start       | (est.)     | Where to Start Tomorrow                 | Fade-in           |
| S38 | 34-close             | 43:30–45:00| Close                                   | Fade-in           |

---

## 2. Production Strategy — Hybrid Pipeline

```
touying/deck.typ
       │
       ▼
typst compile deck.typ
       │
       ▼  (PDF → per-page PNGs at 1920×1080)
slide_pngs/s{01..35}.png
       │
       ├─── simple slides ──→ Manim: FadeIn(ImageMobject("s07.png"))
       │
       └─── animated slides ─→ Manim: dedicated Scene class (see below)
                                        │
                                        ▼
                              rendered MP4 per scene (4K, 60fps)
                                        │
                    ┌───────────────────┴──────────────────────┐
                    ▼                                           ▼
             DaVinci Resolve / kdenlive                  beats.yaml
               (assembly cut, audio sync)              (timing parameters)
```

### Color palette (mirrors touying `pal.*`)

```python
# manim_video/config/palette.py
BG_DARK   = "#14161d"   # pal.bg-dark — scene background
BG_LIGHT  = "#f5f3ec"   # pal.bg — light slide bg (for ImageMobject overlays)
ACCENT    = "#D09757"   # pal.accent ≈ oklch(62% 0.14 55°) — gold/amber
BAD       = "#C44F3E"   # pal.bad ≈ oklch(58% 0.17 28°) — terracotta red
FG_DARK   = "#e8e4d9"   # pal.fg-dark — near-white on dark
FG_DIM    = "#7a7e8a"   # pal.fg-dim — muted text
GOOD      = "#5a9e6a"   # pal.good — green for resolved incidents
ISO_GOLD  = "#F0C060"   # slightly brighter gold for the isomorphism symbol
```

---

## 3. Animation Inventory — Detailed Storyboards

### ★ MANIM A — Gentzen OR Rules (S10, ~9:05–9:35)
*"Logic as local interface"*

**Purpose**: Show ∨I₁, ∨I₂, ∨E appearing as a natural deduction system;
draw the code/logic parallel; set up the Curry-Howard reveal that follows.

**Scene class**: `GentzenOrScene` (30 sec)

#### Phase 1 — Introduction rules build in (0–8s)
- Dark background.
- Left panel label fades in: `"Introduction rules — building A ∨ B"` (small mono text, dim).
- ∨I₁ rule fades in from top: premise `A` over a bar, conclusion `A ∨ B`, label `(∨I₁)` in amber.
- Brief pause, then ∨I₂ does the same: `B` → `A ∨ B`.
- Right panel label fades in: `"On the code side"`.
- Two Scala lines appear: `Left(a)` and `Right(b)` constructors.

#### Phase 2 — Elimination rule builds in (8–16s)
- Left panel: label `"Elimination rule — using A ∨ B"` fades in.
- ∨E rule assembles from top down:
  - Three premises appear left-to-right: `A ∨ B`, `[A]→C`, `[B]→C`.
  - The horizontal bar draws itself (line morph, left to right).
  - Label `(∨E)` fades in amber to the right of the bar.
  - Conclusion `C` drops down below the bar.
- Right panel: match expression appears:
  ```
  x match {
    case Left(a)  => useA(a)   // [A] → C
    case Right(b) => useB(b)   // [B] → C
  }
  ```

#### Phase 3 — The missing-branch flash (16–22s)
- A dimmed "bad" version of the match appears in red:
  ```
  x match {
    case Left(a)  => useA(a)   // [A] → C
    // Right missing
  }
  ```
- The `[B]→C` premise in the ∨E rule also briefly pulses red, indicating the
  structural gap: "no [B]→C means the rule cannot be applied — compile error."

#### Phase 4 — Alignment highlight (22–30s)
- Both the correct match block and the ∨E elimination rule get a gold highlight
  rectangle (rounded, animated outline drawing itself around each).
- A small `≡` (equivalent) glyph fades in between the two panels.
- Caption at bottom: `"Exhaustive match IS ∨-elimination"`.
- Crossfade to S11 convergence slide.

---

### ★ MANIM B — Curry-Howard Isomorphism Reveal (S12, ~9:35–10:05)
*"Proposition = Type. Proof = Program."*

**Purpose**: The centrepiece animation. Two worlds (logic / programming) are shown
in parallel, a specific shared structure is highlighted, the rest of each world dims
and falls away, and the isomorphism symbol unites the extracted pieces.

**Scene class**: `CurryHowardReveal` (25 sec)

#### Setting (0–8s): Two worlds, side by side

- **Left half** (full white, slightly warm, resembling a proof-on-paper aesthetic):
  A natural deduction proof tree for `(A ∨ B) → C` using ∨E.
  ```
              [A]¹     [B]²
               …        …
  A ∨ B        C        C
  ────────────────────────── (∨E, ¹, ²)
              C
  ```
  Text: white/cream on near-black. The whole tree is visible.
  
- **Right half** (same background, slightly cooler):
  A typed lambda calculus term:
  ```
  case(x, λa.f(a), λb.g(b))
       ↑
  x : A ∨ B
  f : A → C
  g : B → C
  ──────────────────
  result : C
  ```

Both sides are present and at full opacity. Small label at top-left: `LOGIC` (dim
amber mono). Small label at top-right: `PROGRAMS` (dim amber mono).

#### Phase 2 — Highlight the shared structure (8–12s)

- A gold bounding box animates itself around the `(∨E, ¹, ²)` rule application
  node in the proof tree (left).
- Simultaneously, a matching gold box draws itself around the `case(...)` term on
  the right.
- Both gold boxes pulse once (brightness +30%).

#### Phase 3 — The pull-out (12–18s)

This is the key animation:

- The two gold-boxed fragments detach from their parent trees/terms.
- They float upward and toward the centre of the upper third of the screen.
- As they rise, the remaining content on each side:
  - Begins to fade from its current colour toward `#2a2d38` (dark grey).
  - Slowly drifts/falls downward at about 30% of its natural speed.
  - By the time the lifted fragments reach the upper third, the fallen content has
    exited the bottom of the frame.
  - The fall uses a slow ease-out (heavy content sinking away).

The overall feel: the two worlds recede as if being lowered into darkness while the
essential shared structure floats upward into the light.

#### Phase 4 — Isomorphism reveal (18–25s)

- The ∨E fragment settles in the upper-left quarter; the `case` fragment settles in
  the upper-right quarter.
- Between them, at horizontal centre, the `≅` symbol fades in (`ISO_GOLD`, size ~120pt).
- Below the `≅`, a single line in small amber mono appears:
  `Proof = Program  ·  Type = Proposition  ·  Simplification = Execution`
- The three pairs appear word by word (left → middle → right), each sub-phrase
  spaced about 0.4s apart.
- Hold for 2s.
- Transition: all content fades out; crossfade to S13 (MLTT slide).

---

### ★ MANIM C — MLTT Π and Σ Types (S13, ~10:05–10:20)
*"Return type computed from argument value."*

**Purpose**: Make the Π-type and Σ-type rules feel like living computation, not
static notation. Show how applying Π-elimination feels like calling a function
whose return type "pops" into specificity.

**Scene class**: `MLTTRulesScene` (15 sec — tight, as this is a brief dwell)

#### Phase 1 — Π-elimination (0–8s)
- The Π-elimination rule appears centrally:
  ```
  f : (Πx:A). B(x)     a : A
  ─────────────────────────────
          f(a) : B(a)
  ```
- `B(x)` in the premise is written with `x` dimly suggesting "a hole."
- After 2s, an animation: `a` (a specific value, e.g., `a = MediumRisk`) slides
  into the `x` position in the conclusion's type, and `B(x)` visibly morphs to
  `B(MediumRisk)`.
- Small label appears beside `B(a)`: `"type depends on value"` (dim amber).

#### Phase 2 — Σ-introduction (8–15s)
- The Σ-introduction rule appears below:
  ```
  a : A     b : B(a)
  ──────────────────
  (a, b) : (Σx:A). B(x)
  ```
- Animate: two values `a` and `b` (where `b`'s type explicitly shows `B(a)`) join
  together with a bracket and the pair type materialises.
- Brief label: `"value + proof that depends on value"`.
- Fade out. Crossfade to S14.

---

### ★ MANIM D — The Lambda Cube (S15, ~10:45–11:30)
*"Three axes, one axis is qualitatively different."*

**Purpose**: Build the lambda cube dimension by dimension so the audience can feel
how each new axis represents a qualitative leap in expressiveness.

**Scene class**: `LambdaCubeScene` (45 sec)

#### Phase 1 — Origin point (0–5s)
- A single glowing point in 3D space (isometric or perspective projection).
- Label: `"λ→ · STLC"` (dim amber). This is the bottom-left-front vertex.
- Caption: `"term on term — every language"`.

#### Phase 2 — Axis 1: Generics (t→T) (5–15s)
- An edge grows rightward from the origin: `"term on type (∀)"`.
- The new vertex lights up: `"λ2 · System F"`.
- Example floats up beside it: `authorize[R <: Risk](...)` in amber code font.
- Caption: `"generics — Stage 2 onwards"`.

#### Phase 3 — Axis 2: Type operators (T→T) (15–25s)
- An edge grows upward: `"type on type"`.
- The new vertex lights up: `"λω"`.
- Example: `List[A], Validator[T]` floats in, then `match types` appears.
- Caption: `"type operators — Stages 5–6"`.

#### Phase 4 — The cube face fills (25–33s)
- The four vertices and four edges of the left face appear, dim.
- Brief hold. Narrator note: "Scala 3 lives on this face."

#### Phase 5 — Axis 3: Dependent types (T→t) (33–45s)
- A new axis grows in the third direction (depth, coming toward the viewer).
- This edge is drawn in BRIGHTER gold, slightly thicker, distinct from the others.
- New vertex: `"λΠ · Idris 2"`.
- Example: `protocolFromSnapshot snap : SessionType` floats in.
- Caption in large text: `"type on term — Stage 6"`.
- The third dimension completes: the full cube wireframe appears.
- One face (the "Stage 6 face") pulses with a subtle amber glow.
- Small text at bottom: `"That third axis is what makes Stage 6 qualitatively different."`.

---

### ★ MANIM E — Bob's Missing Branch + Sum-Type Fix (S20, Stage 3, ~est. 22:00)
*"The compiler enforces ∨-elimination."*

**Purpose**: The most concrete payoff animation. Show the un-sealed Java if/else
failing silently, then watch Scala sealed+exhaustive match make the same code a
compile error.

**Scene class**: `SumTypePayoffScene` (20 sec)

#### Phase 1 — The bad code (0–8s)
- Dark background. Java code appears:
  ```java
  if (risk != HIGH) {
    return fastPath(order);
  }
  return manualReview(order);
  ```
- After 3s, a new value `MEDIUM` floats down from above and lands in the `risk`
  position of the condition.
- The `fastPath` branch highlights: a green checkmark (wrongly) appears. Silent run.
- A red warning icon fades in: `"3DS skipped"`. Fades out.

#### Phase 2 — The sealed fix (8–20s)
- The Java code slides left and dims.
- Scala code slides in from the right:
  ```scala
  risk match {
    case LOW    => fastPath(order)
    case HIGH   => manualReview(order)
    // MEDIUM missing
  }
  ```
- A red underline appears under the `match` keyword.
- A compiler error box pops up: `"Match may not be exhaustive. Missing: MEDIUM"`.
- The missing `case MEDIUM => threeDsFlow(order)` line types itself in with a brief
  gold glow — and the error disappears.
- Caption: `"Adding a new variant forces every match site to handle it."`.

---

### ★ MANIM F — Session Types Protocol + Duality (S27, ~30:00–30:45)
*"Client's send is server's receive."*

**Purpose**: Make `LowRiskProtocol` legible as a sequential conversation, then show
how `Dual[P]` is mechanically computed, making the anti-drift guarantee visual.

**Scene class**: `SessionTypesDualityScene` (45 sec)

#### Phase 1 — Protocol as flow (0–15s)
- A horizontal chain of boxes builds left to right, each box materialising in sequence:
  ```
  [Send Order] → [Receive Snapshot] → [Receive AuthPayment] → [Receive Capture] → [⊕ Choose] → [End]
  ```
- Each box is amber-outlined; arrows between them in dim gold.
- Label above: `"CLIENT VIEW"`.
- After each box appears, a brief type annotation shows the Scala type:
  `Send[Order, ...]`, then `Receive[RiskSnapshot, ...]`, etc.

#### Phase 2 — Dual computation (15–30s)
- A horizontal mirror line appears in the centre of the screen.
- The client chain reflects downward: the reflected chain is identical at first.
- Then: each box in the reflected chain animates its label:
  - `Send` → `Receive` (label morphs with a 180° spin)
  - `Receive` → `Send` (same morph)
  - `Choose` → `Offer` (same morph)
- Label below the reflected chain: `"SERVER VIEW — Dual[P]"`.
- The server chain is now in blue/cool colour (contrasting with the warm amber client chain).

#### Phase 3 — Message passing (30–45s)
- Two "agents" appear (simple circles with labels `C` and `S`) at each end of a
  vertical dividing line.
- Animated messages pass between them: a small packet travels from C to S for Send,
  from S to C for Receive.
- They step through the protocol in sync, each step consuming one node from each chain
  (the consumed nodes dim and shrink).
- When `Choose` is reached, one branch glows.
- At `End`, both agents briefly glow green.
- Caption: `"Protocol mismatch = compile error, not runtime hang."`.

---

### ★ MANIM G — The Climb / Summary (S34, ~41:00–42:00)
*"What was removed at each stage."*

**Purpose**: Satisfying culmination animation. Each stage row in the summary table
rolls in, accompanied by the specific incident it closed. The four incident badges
pop in at the end.

**Scene class**: `TheClimbScene` (60 sec)

#### Phase 1 — Table construction (0–40s)
- Dark background. The three-column table header appears first (Stage / Language / What prevented).
- Rows appear one by one, from Stage 0 to Stage 6, each triggered ~5s apart.
- As each row appears, a small icon on the right briefly flashes if it closes one of
  the four incidents (e.g., Stage 1 row → Alice's JS bug icon briefly pulses red then green).
- Stage 6's row appears in slightly brighter text.

#### Phase 2 — Ladder reveal (40–52s)
- Below the table, the three-column DOCUMENTED / TESTED / ENCODED ladder fades in.
- The ENCODED column is gold-highlighted (matching the touying `encoded-active: true`).

#### Phase 3 — Incident badge pop (52–60s)
- Four small badges animate in from the bottom, one by one:
  `✓ Alice — boundary` · `✓ Bob — approval` · `✓ Charlie — lifecycle` · `✓ Danielle — protocol`
- Each badge pops with a small scale-up + gold glow before settling.
- Hold for 1s, then crossfade to S35.

---

## 4. Beat Timing Control System

### `manim_video/config/beats.yaml`

Every animation beat is named and parameterised. After recording audio, you adjust
numbers in this file — no Python changes needed.

```yaml
# ─────────────────────────────────────────────────────────────────────────────
# GLOBAL
# ─────────────────────────────────────────────────────────────────────────────
video_fps: 60
resolution: [3840, 2160]   # 4K; render at 1080p first for iteration

# ─────────────────────────────────────────────────────────────────────────────
# SCENE: GentzenOrScene   (S10, ~9:05 in talk)
# ─────────────────────────────────────────────────────────────────────────────
gentzen_or:
  audio_offset_s: 9.05      # seconds from talk start where this scene begins
  total_dur_s: 30.0

  beats:
    vi_rules_appear:     { t: 0.0,  dur: 3.0 }
    code_intro_appear:   { t: 1.5,  dur: 2.5 }
    ve_rule_appear:      { t: 5.0,  dur: 4.0 }
    match_appear:        { t: 7.0,  dur: 3.0 }
    bad_branch_flash:    { t: 14.0, dur: 2.5 }
    highlight_draw:      { t: 19.0, dur: 2.5 }
    equivalence_appear:  { t: 22.5, dur: 1.5 }
    caption_appear:      { t: 24.0, dur: 1.0 }
    hold:                { t: 25.0, dur: 5.0 }

# ─────────────────────────────────────────────────────────────────────────────
# SCENE: CurryHowardReveal   (S12, ~9:35 in talk)
# ─────────────────────────────────────────────────────────────────────────────
curry_howard:
  audio_offset_s: 9.55
  total_dur_s: 25.0

  beats:
    logic_side_appear:   { t: 0.0,  dur: 2.5 }
    program_side_appear: { t: 1.5,  dur: 2.5 }
    labels_appear:       { t: 3.5,  dur: 1.0 }
    highlight_both:      { t: 5.0,  dur: 2.0 }
    highlight_pulse:     { t: 7.0,  dur: 0.5 }
    pull_up_duration:    { t: 8.0,  dur: 3.5 }  # lifted fragments float up
    rest_fall_duration:  { t: 8.5,  dur: 3.0 }  # rest dims and falls
    iso_symbol_appear:   { t: 12.0, dur: 1.5 }
    caption_appear:      { t: 14.0, dur: 2.5 }  # "Proof = Program · Type = Proposition …"
    hold:                { t: 18.0, dur: 7.0 }

  easing:
    pull_up:   "ease_out_cubic"
    fall_away: "ease_in_quad"
    iso:       "ease_out_back"   # slight overshoot for tactile feel

# ─────────────────────────────────────────────────────────────────────────────
# SCENE: MLTTRulesScene   (S13, ~10:05 in talk)
# ─────────────────────────────────────────────────────────────────────────────
mltt_rules:
  audio_offset_s: 10.08
  total_dur_s: 15.0

  beats:
    pi_rule_appear:      { t: 0.0,  dur: 2.0 }
    value_substitution:  { t: 3.5,  dur: 1.5 }  # B(x) → B(MediumRisk) morph
    pi_label_appear:     { t: 5.5,  dur: 1.0 }
    sigma_rule_appear:   { t: 7.0,  dur: 2.0 }
    sigma_pair_animate:  { t: 10.0, dur: 1.5 }
    sigma_label_appear:  { t: 12.0, dur: 1.0 }
    hold:                { t: 13.0, dur: 2.0 }

# ─────────────────────────────────────────────────────────────────────────────
# SCENE: LambdaCubeScene   (S15, ~10:45 in talk)
# ─────────────────────────────────────────────────────────────────────────────
lambda_cube:
  audio_offset_s: 10.75
  total_dur_s: 45.0

  beats:
    origin_appear:       { t: 0.0,  dur: 2.0 }
    axis1_grow:          { t: 4.0,  dur: 3.0 }   # t→T axis
    axis1_label:         { t: 7.5,  dur: 1.5 }
    axis2_grow:          { t: 13.0, dur: 3.0 }   # T→T axis
    axis2_label:         { t: 16.5, dur: 1.5 }
    face_fill:           { t: 22.0, dur: 3.0 }   # Scala face
    face_label:          { t: 25.5, dur: 1.0 }
    axis3_grow:          { t: 31.0, dur: 4.0 }   # T→t axis — BRIGHTER, THICKER
    axis3_label:         { t: 35.5, dur: 2.0 }
    cube_complete:       { t: 38.0, dur: 2.5 }
    stage6_glow:         { t: 40.5, dur: 2.0 }
    caption_appear:      { t: 42.5, dur: 2.5 }

  style:
    axis3_color:   "#F0C060"   # ISO_GOLD — distinguishes the dependent-type axis
    axis3_stroke:  3.0         # wider than axes 1 and 2 (which are 1.5)
    other_stroke:  1.5

# ─────────────────────────────────────────────────────────────────────────────
# SCENE: SumTypePayoffScene   (S20/S21, ~22:00 in talk)
# ─────────────────────────────────────────────────────────────────────────────
sum_type_payoff:
  audio_offset_s: 22.0
  total_dur_s: 20.0

  beats:
    java_appear:         { t: 0.0,  dur: 2.0 }
    medium_drops_in:     { t: 3.5,  dur: 1.0 }
    fast_path_flash:     { t: 5.0,  dur: 1.5 }
    warning_appear:      { t: 6.5,  dur: 1.0 }
    java_slides_away:    { t: 8.0,  dur: 1.5 }
    scala_slides_in:     { t: 8.5,  dur: 2.0 }
    error_underline:     { t: 11.0, dur: 1.0 }
    error_box_appear:    { t: 12.0, dur: 1.5 }
    missing_case_types:  { t: 14.5, dur: 2.0 }
    error_dissolves:     { t: 16.5, dur: 1.0 }
    caption_appear:      { t: 18.0, dur: 2.0 }

# ─────────────────────────────────────────────────────────────────────────────
# SCENE: SessionTypesDualityScene   (S27, ~30:00 in talk)
# ─────────────────────────────────────────────────────────────────────────────
session_types:
  audio_offset_s: 30.0
  total_dur_s: 45.0

  beats:
    label_client_appear:    { t: 0.0,  dur: 0.5 }
    box_send_order:         { t: 1.0,  dur: 0.8 }
    box_recv_snapshot:      { t: 2.0,  dur: 0.8 }
    box_recv_authpay:       { t: 3.0,  dur: 0.8 }
    box_recv_capture:       { t: 4.0,  dur: 0.8 }
    box_choose:             { t: 5.0,  dur: 0.8 }
    box_end:                { t: 6.0,  dur: 0.8 }
    mirror_line_appear:     { t: 10.0, dur: 1.0 }
    dual_chain_reflect:     { t: 11.5, dur: 2.0 }
    label_flip_send_recv:   { t: 14.0, dur: 2.5 }  # labels morph one by one
    label_server_appear:    { t: 17.5, dur: 0.8 }
    agents_appear:          { t: 22.0, dur: 1.0 }
    message_step_1:         { t: 24.0, dur: 1.5 }  # Order sent
    message_step_2:         { t: 26.0, dur: 1.5 }  # Snapshot received
    message_step_3:         { t: 28.0, dur: 1.5 }
    message_step_4:         { t: 30.0, dur: 1.5 }
    choose_branch_glow:     { t: 32.0, dur: 1.0 }
    end_both_green:         { t: 34.0, dur: 1.5 }
    caption_appear:         { t: 37.0, dur: 2.0 }
    hold:                   { t: 39.0, dur: 6.0 }

# ─────────────────────────────────────────────────────────────────────────────
# SCENE: TheClimbScene   (S34, ~41:00 in talk)
# ─────────────────────────────────────────────────────────────────────────────
the_climb:
  audio_offset_s: 41.0
  total_dur_s: 60.0

  beats:
    header_appear:          { t: 0.0,  dur: 1.0 }
    row_stage0:             { t: 1.5,  dur: 1.0 }
    row_stage1:             { t: 5.0,  dur: 1.0 }
    row_stage2:             { t: 9.0,  dur: 1.0 }
    row_stage3:             { t: 13.0, dur: 1.0 }
    row_stage4:             { t: 17.0, dur: 1.0 }
    row_stage5:             { t: 21.0, dur: 1.0 }
    row_stage6:             { t: 25.5, dur: 1.2 }  # slightly longer pause on final row
    ladder_appear:          { t: 30.0, dur: 2.0 }
    badge_alice:            { t: 35.0, dur: 0.8 }
    badge_bob:              { t: 36.5, dur: 0.8 }
    badge_charlie:          { t: 38.0, dur: 0.8 }
    badge_danielle:         { t: 39.5, dur: 0.8 }
    hold:                   { t: 42.0, dur: 18.0 }
```

### Loading beats in Python

```python
# manim_video/beats_loader.py
import yaml, pathlib

_beats = None

def load():
    global _beats
    if _beats is None:
        p = pathlib.Path(__file__).parent / "config" / "beats.yaml"
        _beats = yaml.safe_load(p.read_text())
    return _beats

def beat(scene: str, name: str) -> dict:
    """Return {'t': float, 'dur': float} for a named beat."""
    return load()[scene]["beats"][name]

def wait(scene: str, name: str) -> float:
    """Convenience: duration of the beat (for self.wait() calls)."""
    return load()[scene]["beats"][name]["dur"]

def offset(scene: str) -> float:
    return load()[scene]["audio_offset_s"]
```

### Using beats in a scene

```python
# manim_video/scenes/07_curry_howard.py
from manim import *
from ..beats_loader import beat, wait
import sys; sys.path.insert(0, "..")
from config.palette import *

class CurryHowardReveal(Scene):
    def construct(self):
        self.camera.background_color = BG_DARK
        b = lambda name: beat("curry_howard", name)

        # — Build the logic side —
        logic_tree = self._build_logic_tree()
        prog_term  = self._build_program_term()

        # Phase 1: both worlds appear
        self.play(FadeIn(logic_tree),  run_time=b("logic_side_appear")["dur"])
        self.play(FadeIn(prog_term),   run_time=b("program_side_appear")["dur"])
        self.wait(wait("curry_howard", "labels_appear"))

        # Phase 2: highlight the ∨E node and the case(...) term
        ve_box   = SurroundingRectangle(logic_tree.ve_node,   color=ACCENT, buff=0.15)
        case_box = SurroundingRectangle(prog_term.case_term,  color=ACCENT, buff=0.15)
        self.play(Create(ve_box), Create(case_box),
                  run_time=b("highlight_both")["dur"])
        self.play(ve_box.animate.set_stroke(width=4),
                  case_box.animate.set_stroke(width=4),
                  run_time=b("highlight_pulse")["dur"])

        # Phase 3: pull-out — fragments lift, rest falls and dims
        ve_fragment   = logic_tree.ve_node.copy()
        case_fragment = prog_term.case_term.copy()

        target_left  = UP * 2 + LEFT  * 3
        target_right = UP * 2 + RIGHT * 3

        self.play(
            # Fragments float up
            ve_fragment.animate.move_to(target_left),
            case_fragment.animate.move_to(target_right),
            # Rest of logic tree dims + falls
            logic_tree.rest.animate.set_opacity(0.1).shift(DOWN * 5),
            prog_term.rest.animate.set_opacity(0.1).shift(DOWN * 5),
            # The original highlighted boxes follow the fragments
            ve_box.animate.move_to(target_left),
            case_box.animate.move_to(target_right),
            run_time=b("pull_up_duration")["dur"],
            rate_func=rate_functions.ease_out_cubic,
        )

        # Phase 4: isomorphism symbol
        iso = MathTex(r"\cong", color=ISO_GOLD, font_size=120)
        iso.move_to(ORIGIN + UP * 2)
        self.play(GrowFromCenter(iso, run_time=b("iso_symbol_appear")["dur"]))

        caption = Text(
            "Proof = Program  ·  Type = Proposition  ·  Simplification = Execution",
            color=ACCENT, font_size=22,
        ).next_to(iso, DOWN * 2)
        self.play(Write(caption, run_time=b("caption_appear")["dur"]))
        self.wait(wait("curry_howard", "hold"))
```

---

## 5. Project File Structure

```
manim_video/
├── config/
│   ├── beats.yaml           ← all timing parameters; tune here after audio recording
│   └── palette.py           ← colour constants matching touying pal.*
│
├── lib/
│   ├── beats_loader.py      ← YAML loader + convenience accessors
│   ├── nd_rule.py           ← Manim helper: natural-deduction inference rule mobject
│   ├── slide_import.py      ← wraps ImageMobject for slide-PNG import
│   └── transitions.py       ← shared: FadeToSlide, SlideOut, ShieldPop
│
├── scenes/
│   ├── 00_title.py          ← S1 title card (FadeIn slide)
│   ├── 01_incidents.py      ← S2–S5 incident code-reveal
│   ├── 02_pattern.py        ← S6 pattern sequential reveal
│   ├── 03_timeline.py       ← S7–S8 history beat-grid
│   ├── 04_convergence.py    ← S9, S11, S14 convergence slides
│   ├── 05_gentzen_or.py     ← S10 ★ MANIM A
│   ├── 06_curry_howard.py   ← S12 ★ MANIM B
│   ├── 07_mltt.py           ← S13 ★ MANIM C
│   ├── 08_lambda_cube.py    ← S15 ★ MANIM D
│   ├── 09_stages.py         ← S16–S20, S22–S26, S31–S33 (slide images + code fades)
│   ├── 10_sum_type_payoff.py ← S20/S21 ★ MANIM E
│   ├── 11_session_types.py  ← S27 ★ MANIM F
│   ├── 12_climb.py          ← S34 ★ MANIM G
│   ├── 13_agentic.py        ← S35 fade-in
│   └── 14_close.py          ← S38 close
│
├── slide_pngs/              ← auto-generated from touying PDF (see Makefile)
│   ├── s01.png … s35.png
│
├── main.py                  ← stitches all scenes; pass --scene NAME for single scene
├── render.sh                ← quality presets: draft (480p), review (1080p), final (4K)
└── README.md
```

---

## 6. Slide Export Command

```makefile
# Add to Makefile
slide-pngs:
	typst compile touying/deck.typ /tmp/deck.pdf
	mkdir -p manim_video/slide_pngs
	pdftoppm -r 192 -png /tmp/deck.pdf manim_video/slide_pngs/s
	# rename pdftoppm output (s-001.png → s01.png etc.)
	python3 scripts/rename_slides.py
```

---

## 7. Implementation Priority Order

### Phase 1 — Foundation (do first, enables everything else)
1. `config/palette.py` and `config/beats.yaml` (skeleton with placeholder times)
2. `lib/beats_loader.py`
3. Slide PNG export (`make slide-pngs`)
4. `lib/slide_import.py` — verify one slide displays correctly at 16:9 4K
5. A minimal `main.py` that plays slide 1 through slide 35 as sequential `FadeIn`s —
   confirms the whole pipeline works before any real animation.

### Phase 2 — Core animations (in this order, as they appear in the talk)
6. **★ MANIM A** `05_gentzen_or.py` — builds on existing ND-rule Typst code; the rules
   themselves are just MathTex.
7. **★ MANIM B** `06_curry_howard.py` — the centrepiece; plan to spend the most time here.
8. **★ MANIM D** `08_lambda_cube.py` — 3D cube in Manim; use `ThreeDScene` with custom
   edge `Line3D` objects; the isometric projection can be faked in 2D if 3D is too slow
   to render.
9. **★ MANIM F** `11_session_types.py` — protocol flow + duality flip.

### Phase 3 — Supporting animations
10. **★ MANIM C** `07_mltt.py`
11. **★ MANIM E** `10_sum_type_payoff.py`
12. **★ MANIM G** `12_climb.py`

### Phase 4 — Incident slides and stage slides
13. `01_incidents.py` — code-reveal for S2–S5 (most tedious but important for the hook)
14. `09_stages.py` — code-fade-in for the stage openers

### Phase 5 — Audio sync
15. Record the talk audio.
16. In a DAW / Audacity: mark the timestamp of each beat mentioned in `beats.yaml` —
    write the `audio_offset_s` values.
17. Adjust individual `dur` and `t` values in `beats.yaml` until animation events match
    the spoken beats.
18. Final render at 4K 60fps.

---

## 8. Key Design Decisions and Trade-offs

### Dark background throughout
Manim's default dark background (`#14161d`) matches the touying dark slides (S1, stage
openers). For slides shown as `ImageMobject` (touying light slides), the image is
letterboxed over the dark background — consistent with the "slide inside the video"
aesthetic of 3Blue1Brown.

### The Curry-Howard reveal is the centrepiece
The conceptual heart of the talk is S12 (the dedicated Curry-Howard slide). Every other animation either builds
toward it (S10 Gentzen), extends it (S13 MLTT), or applies it concretely (S20 Bob's
branch, S27 session types). Invest the most polish here.

### Keep MathTex consistent with the ND rules in touying
The Typst `nd-rule` function renders `A ∨ B`, `∨I₁`, `∨E` with Unicode symbols.
In MathTex use: `A \vee B`, `{\vee}I_1`, `{\vee}E` to match exactly.

### `beats.yaml` is the production control surface
All timing lives in YAML. The Python code never has `self.wait(2.5)` literals —
only `self.wait(wait("scene", "beat"))`. This discipline is what makes the
audio-sync pass fast: open `beats.yaml`, change a number, re-render the scene.

### Render strategy
- During development: `manim -pql scene.py SceneName` (480p, fast)
- During review: `manim -pqm scene.py SceneName` (720p)
- Final: `manim -pqk scene.py SceneName` (4K, use `-r 3840,2160`)
- `render.sh` encodes the presets.

---

## 9. Notes on Specific Mathematical Content

### The pull-out animation: what to show on each side

For **MANIM B** (Curry-Howard), the two panels should show:

**Left — Natural deduction proof of `(A ∨ B) → C`**
```
  [A]¹     [B]²
   ⋮         ⋮
   C         C
  A ∨ B
  ──────────────  ∨E (¹,²)
       C
```

**Right — Typed lambda term**
```
λx : A ∨ B.
  case x of
  | inl a ↦ f a      (f : A → C)
  | inr b ↦ g b      (g : B → C)
: C
```

The highlighted fragments:
- Left: the `∨E (¹,²)` rule application (the horizontal bar + label + conclusion node)
- Right: the `case x of ...` expression

These are structurally isomorphic. Pulling them together and placing `≅` between them
is the punchline.

### Lambda cube vertices (exact labels for Manim)

| Vertex | Name | Label for Manim |
|--------|------|-----------------|
| λ→     | STLC | `\lambda{\to}` |
| λ2     | System F (generics) | `\lambda{2}` |
| λω̄     | System F_ω | `\lambda\underline{\omega}` |
| λP     | LF (dependent) | `\lambda{P}` |
| λ2+ω   | Haskell98 territory | — |
| λC     | Calculus of Constructions | `\lambda{C}` |
| λ2+P   | — | — |
| λP+ω̄   | Idris 2 / Agda | `\lambda{P}\underline{\omega}` |

In the animation, use informal labels (`"Generics"`, `"Type operators"`, `"Dependent types"`)
as primary text, with the formal λ-names as small subscripts. The audience is practitioners,
not type theorists.

### The `≅` symbol
Use `\cong` in MathTex. Render at 120–140pt. Apply `ISO_GOLD = "#F0C060"` — slightly
brighter than `ACCENT` so it "pops" over both the lifted content and the dark background.
The `GrowFromCenter` + `ease_out_back` easing (slight overshoot) gives it the tactile
weight the moment deserves.

---

## 10. Code Examples, Syntax Highlighting, Compiler Errors, and Demo Output

### 10.1 Three-Tier Strategy

Not all code in the video needs the same treatment. The key insight from reading
`code-pane.typ` is that the touying component already covers static display
beautifully — including per-line highlight tints (`kind: "err" | "hl" | "hl-good"`),
hover-pop overlays, and diagnostic strips. For anything static, the slide PNG is
both easier and better than re-implementing the layout in Manim.

| Tier | When to use | How |
|------|-------------|-----|
| **T1 — Slide PNG** | Code is shown as-is, no per-beat animation | `ImageMobject("s{n}.png")` + `FadeIn` |
| **T2 — PNG variants** | Need to cross-dissolve between two states of the same code (e.g. clean → with compiler error) | Export two PNGs from touying (one per state via the `highlights`/`diagnostic` params); `FadeTransform(img_a, img_b)` in Manim |
| **T3 — Live CodePanel** | A specific token must animate (drop in, type itself, get underlined); the animation is the beat | Custom Manim `CodePanel` class — Pygments tokenizer → `VGroup` of coloured `Text` objects |

**Which scenes use which tier:**

| Scene | Code content | Tier |
|-------|-------------|------|
| S2–S5 (incidents) | Bug-line code blocks inside 2-column slide | T1 + overlay (see §10.5) |
| S18–S26, S29–S33 (stage slides) | Scala / Java / Idris code panels | T1 (slide PNGs are pixel-perfect) |
| MANIM A — Gentzen OR (S10) | Scala `match` block | T3 — line reveal + bad-branch flash |
| MANIM B — Curry-Howard (S11) | Lambda-calculus term | **MathTex** (proof notation, not IDE panel — §10.6) |
| MANIM C — MLTT (S13) | Π/Σ rules | **MathTex** only |
| MANIM E — Sum-type payoff (S20) | Java if/else + Scala match | T3 — both panels, `MEDIUM` token animation |
| MANIM F — Session types (S27) | `LowRiskProtocol` type | T3 — protocol type spelled as tokens that arrange into flow diagram |
| S32 — MLTT running (demo) | Idris `protocolFromSnapshot`, `assessOrder` | T2 (clean → with hover-pop) |
| Stage 6 linearity demo | Idris `finish` commented out | T3 — compiler error animation |

---

### 10.2 Exact Colour Mapping (from `theme.typ` `pal.c-*`)

The theme file defines code colours in OKLCH. Converted to hex for Manim:

```python
# manim_video/config/palette.py  (add to existing file)

# ── Code syntax colours — exact mapping from pal.c-* in theme.typ ──────────
# oklch(78%, 0.10,  60°) ≈ warm gold
C_KEYWORD   = "#D4A86A"   # pal.c-key  — val, def, sealed, match, type, fun
# oklch(80%, 0.10, 200°) ≈ steel blue
C_TYPE      = "#6FCFD8"   # pal.c-type — type names, type params, class names
# oklch(78%, 0.10, 130°) ≈ sage green
C_STRING    = "#8DC07A"   # pal.c-str  — string/char literals
# oklch(78%, 0.10,  25°) ≈ coral/salmon
C_NUMBER    = "#D4826A"   # pal.c-num  — numeric literals
# oklch(58%, 0.02, 100°) ≈ desaturated olive-grey
C_COMMENT   = "#7A7D70"   # pal.c-com  — line/block comments
# oklch(80%, 0.10,  80°) ≈ bright warm amber
C_FUNCTION  = "#C8A84E"   # pal.c-fn   — function/method names
# ── Panel chrome
CODE_BG      = "#1a1d26"   # pal.bg-dark-2     — code panel background
CODE_TAB_BG  = "#11131a"   # pal.bg-dark        — tab bar background
CODE_DIAG_BG = "#232634"   # pal.bg-dark-3      — diagnostic strip background
GUTTER_FG    = "#494c58"   # hard-coded in code-pane.typ line-number colour
CODE_DEFAULT = "#E8E2D2"   # pal.fg-dark        — identifiers, brackets, default
CODE_DIM     = "#9B988A"   # pal.fg-dark-dim    — dimmed tokens
```

**Pygments → colour mapping:**

```python
from pygments import token as T

SYNTAX = {
    T.Keyword:                  C_KEYWORD,
    T.Keyword.Declaration:      C_KEYWORD,
    T.Keyword.Type:             C_TYPE,
    T.Name.Class:               C_TYPE,
    T.Name.Namespace:           C_TYPE,
    T.Name.Builtin.Pseudo:      C_KEYWORD,    # true, false, null
    T.Name.Function:            C_FUNCTION,
    T.Name.Function.Magic:      C_FUNCTION,
    T.Name.Decorator:           C_NUMBER,     # @annotation — use coral
    T.Literal.String:           C_STRING,
    T.Literal.String.Doc:       C_COMMENT,    # docstrings → comment colour
    T.Literal.Number:           C_NUMBER,
    T.Comment:                  C_COMMENT,
    T.Comment.Single:           C_COMMENT,
    T.Operator:                 "#89CCDF",    # slightly lighter cyan for =>  →  ::
    T.Punctuation:              CODE_DIM,
    T.Error:                    BAD,
    T.Token:                    CODE_DEFAULT, # catch-all
}

def token_color(ttype):
    """Walk up the Pygments token hierarchy until we find a mapping."""
    while ttype:
        if ttype in SYNTAX:
            return SYNTAX[ttype]
        ttype = ttype.parent
    return CODE_DEFAULT
```

---

### 10.3 The `CodePanel` Class (Tier 3)

This class replicates the `code-pane.typ` chrome in Manim:
- Tab bar with amber dot + filename
- Line-number gutter
- Syntax-highlighted code body
- Optional diagnostic strip (matching the `diagnostic` parameter from `code-pane.typ`)

Each token is an **individual `Text` mobject**, enabling per-token animation.
Lines are `VGroup`s of token `Text` objects, positioned left-to-right.
The full code body is a `VGroup` of line `VGroup`s.

```python
# manim_video/lib/code_panel.py
from manim import *
from pygments import lex
from pygments.lexers import get_lexer_by_name
from .palette import *
from .syntax import token_color

FONT = "JetBrains Mono"

class CodePanel(VGroup):
    """
    Replicates the touying code-pane component as a Manim VGroup.

    Parameters
    ----------
    code        : str   — source code string (no leading/trailing blank lines)
    language    : str   — Pygments language name ('scala', 'java', 'haskell', 'javascript')
    filename    : str   — displayed in the tab bar
    width       : float — Manim units
    font_size   : int   — pt, typically 20–24
    show_gutter : bool  — display line numbers (default True)
    """
    def __init__(self, code: str, language: str, filename: str = "Demo.scala",
                 width: float = 7.0, font_size: int = 20,
                 show_gutter: bool = True, **kwargs):
        super().__init__(**kwargs)
        self.code_str   = code
        self.language   = language
        self.font_size  = font_size
        self.line_height = font_size * 0.017  # calibrate to Manim units
        self.char_width  = font_size * 0.010  # monospace char width estimate

        # ── Panel background ───────────────────────────────────────────────
        panel_h = self._estimate_height(code)
        self.bg = RoundedRectangle(
            width=width, height=panel_h,
            corner_radius=0.15,
            fill_color=CODE_BG, fill_opacity=1,
            stroke_color=GUTTER_FG, stroke_width=0.8,
        )

        # ── Tab bar ────────────────────────────────────────────────────────
        tab_h = 0.45
        self.tab = Rectangle(
            width=width, height=tab_h,
            fill_color=CODE_TAB_BG, fill_opacity=1,
            stroke_width=0,
        ).align_to(self.bg, UP + LEFT)

        amber_dot = Dot(radius=0.07, color=ACCENT)
        fname = Text(filename, font=FONT, font_size=font_size - 4,
                     color=CODE_DEFAULT, weight=BOLD)
        tab_content = VGroup(amber_dot, fname).arrange(RIGHT, buff=0.12)
        tab_content.move_to(self.tab.get_left() + RIGHT * 0.4)
        tab_content.align_to(self.tab, LEFT).shift(RIGHT * 0.25)

        tab_divider = Line(
            self.tab.get_left() + DOWN * tab_h/2,
            self.tab.get_right() + DOWN * tab_h/2,
            color=GUTTER_FG, stroke_width=0.8,
        )

        self.tab_group = VGroup(self.tab, tab_content, tab_divider)

        # ── Code lines ────────────────────────────────────────────────────
        self.lines_group = self._build_lines(code, language, show_gutter)
        self.lines_group.next_to(self.tab, DOWN, buff=0.15)
        self.lines_group.align_to(self.bg, LEFT).shift(RIGHT * (0.5 if show_gutter else 0.25))

        self.add(self.bg, self.tab_group, self.lines_group)

    def _build_lines(self, code, language, show_gutter):
        lexer = get_lexer_by_name(language, stripall=False)
        # Split into lines while preserving token boundaries
        raw_lines = code.split("\n")
        all_lines = []
        for i, src_line in enumerate(raw_lines):
            line_n = i + 1
            tokens = list(lex(src_line, lexer))
            token_texts = []
            if show_gutter:
                gnum = Text(f"{line_n:2d}", font=FONT,
                            font_size=self.font_size - 2, color=GUTTER_FG)
                token_texts.append(gnum)
            for ttype, ttext in tokens:
                if ttext.strip() == "" and ttext != " ":
                    continue  # skip pure-newline tokens
                t = Text(ttext, font=FONT, font_size=self.font_size,
                         color=token_color(ttype))
                token_texts.append(t)
            if token_texts:
                line_group = VGroup(*token_texts).arrange(RIGHT, buff=0)
                all_lines.append(line_group)
        return VGroup(*all_lines).arrange(DOWN, buff=0.08, aligned_edge=LEFT)

    # ── Animation helpers ─────────────────────────────────────────────────

    def get_line(self, n: int) -> VGroup:
        """Return the VGroup for line n (1-indexed)."""
        return self.lines_group[n - 1]

    def reveal_lines(self, start=1, end=None, lag=0.12) -> Animation:
        """FadeIn each line with a stagger — 'dropping into place' feel."""
        lines = list(self.lines_group[start-1:end])
        return AnimationGroup(
            *[FadeIn(l, shift=DOWN * 0.06) for l in lines],
            lag_ratio=lag,
        )

    def highlight_line_bg(self, n: int, color=BAD, opacity=0.25) -> Animation:
        """Animate a background tint behind line n."""
        line = self.get_line(n)
        bg = BackgroundRectangle(line, color=color, buff=0.06,
                                 fill_opacity=opacity)
        return FadeIn(bg)

    def error_underline(self, n: int, color=BAD) -> Animation:
        """Draw a red underline beneath the tokens on line n."""
        line = self.get_line(n)
        ul = Underline(line, color=color, stroke_width=2)
        return Create(ul)

    def type_in_line(self, text: str, after_line: int,
                     language: str = None) -> AnimationGroup:
        """Type a new code line after line `after_line`."""
        lang = language or self.language
        tokens = list(lex(text, get_lexer_by_name(lang)))
        token_mobs = [Text(t, font=FONT, font_size=self.font_size,
                           color=token_color(tt)) for tt, t in tokens if t.strip()]
        new_line = VGroup(*token_mobs).arrange(RIGHT, buff=0)
        prev_line = self.get_line(after_line)
        new_line.next_to(prev_line, DOWN, buff=0.08, aligned_edge=LEFT)
        # Reveal character by character using AddTextLetterByLetter per token
        return LaggedStart(
            *[AddTextLetterByLetter(t, run_time=0.05 * len(t.original_text))
              for t in token_mobs],
            lag_ratio=0.0,
        )

    def add_diagnostic(self, kind: str, label: str, message: str) -> "DiagnosticStrip":
        """Attach a DiagnosticStrip below the panel (returns the mobject)."""
        strip = DiagnosticStrip(kind, label, message, width=self.bg.width)
        strip.next_to(self.bg, DOWN, buff=0)
        self.add(strip)
        return strip
```

---

### 10.4 The `DiagnosticStrip` Class

Replicates the touying `code-pane.typ` diagnostic strip (the coloured output bar
beneath the code block). Used for compiler errors and type-check output.

```python
# manim_video/lib/diagnostic_strip.py
class DiagnosticStrip(VGroup):
    """
    Mimics the touying code-pane `diagnostic` strip.

    kind    : 'bad' | 'good' | 'note'
    label   : short prefix, e.g. 'error[E0001]' or 'type mismatch'
    message : full message text
    """
    def __init__(self, kind: str, label: str, message: str,
                 width: float = 7.0, font_size: int = 18, **kwargs):
        super().__init__(**kwargs)

        color_map = {"bad": BAD, "good": GOOD, "note": ACCENT}
        label_color = color_map.get(kind, ACCENT)

        strip_h = 0.55
        bg = Rectangle(width=width, height=strip_h,
                        fill_color=CODE_DIAG_BG, fill_opacity=1, stroke_width=0)
        left_border = Line(
            bg.get_corner(UL), bg.get_corner(DL),
            color=label_color, stroke_width=3,
        )
        label_txt = Text(label, font=FONT, font_size=font_size,
                         color=label_color, weight=BOLD)
        msg_txt   = Text(message, font=FONT, font_size=font_size,
                         color=CODE_DEFAULT)
        content = VGroup(label_txt, msg_txt).arrange(RIGHT, buff=0.2)
        content.move_to(bg).shift(RIGHT * 0.15)

        self.add(bg, left_border, content)

    def appear(self) -> Animation:
        return FadeIn(self, shift=UP * 0.1)
```

**Usage in MANIM E (Bob's Scala match):**

```python
panel = CodePanel(scala_match_code, "scala", "RiskEngine.scala", width=6.5)
self.play(FadeIn(panel))
self.wait(2.0)

# Show error underline on the match keyword (line 1)
self.play(panel.error_underline(1))

# Attach and reveal the diagnostic strip
diag = panel.add_diagnostic(
    kind="bad",
    label="error",
    message="Match may not be exhaustive — missing case: MEDIUM"
)
self.play(diag.appear())
self.wait(1.5)

# Type in the missing case with gold glow
self.play(panel.type_in_line("    case MEDIUM => threeDsFlow(order)", after_line=3))
self.play(FadeOut(diag))   # error resolved — strip disappears
```

---

### 10.5 Overlay-on-PNG for Incident Slides (T2 hybrid)

The incident slides (S2–S5) have a complex two-column layout (112pt person name,
full paragraph story, code block inside a coloured callout). Rebuilding this in Manim
is not worth the cost. Use the slide PNG as a base and **overlay Manim objects** at
known pixel coordinates.

```python
# manim_video/lib/slide_overlay.py

class SlideWithOverlay(Scene):
    """
    Load a slide PNG and animate Manim overlay objects on top.
    Coordinate system: Manim's default (centre = origin, ±4 vertical, ±7 horizontal).
    """
    def show_slide(self, png_path: str):
        img = ImageMobject(png_path)
        img.set_height(8.0)   # fill full 16:9 frame
        self.add(img)
        return img

    def highlight_region(self, x: float, y: float,
                         w: float, h: float,
                         color=BAD, opacity=0.28) -> Animation:
        """
        Animate a translucent highlight rectangle.
        x, y: centre position in Manim coords (convert from slide-px once, hardcode).
        """
        rect = Rectangle(width=w, height=h,
                         fill_color=color, fill_opacity=opacity,
                         stroke_color=color, stroke_width=1.2)
        rect.move_to([x, y, 0])
        return FadeIn(rect)

    def type_annotation(self, text: str, x: float, y: float,
                        color=BAD) -> Animation:
        """Pop-in text annotation beside a highlighted region."""
        label = Text(text, font=FONT, font_size=20, color=color)
        label.move_to([x, y, 0])
        return GrowFromCenter(label)
```

**Coordinate calibration** — do once per slide, hardcode in `beats.yaml`:

```yaml
# beats.yaml additions for incident slides
incidents:
  alice:
    slide_png: "slide_pngs/s02.png"
    bug_line_region: { x: 1.9, y: -0.7, w: 5.0, h: 0.38 }
    annotation_pos:  { x: 4.8, y: -0.7 }
    annotation_text: "\"4500\" + \"1500\" = \"45001500\""
  bob:
    slide_png: "slide_pngs/s03.png"
    bug_line_region: { x: 1.9, y: -0.3, w: 5.0, h: 0.38 }
    annotation_text: "MEDIUM hits fastPath()"
  charlie:
    slide_png: "slide_pngs/s04.png"
    bug_line_region: { x: 1.9, y:  0.1, w: 5.0, h: 0.38 }
    annotation_text: "state never checked"
  danielle:
    slide_png: "slide_pngs/s05.png"
    bug_line_region: { x: 1.9, y: -0.5, w: 5.0, h: 0.76 }  # two lines
    annotation_text: "client hangs"
```

The `bug_line_region` values are calculated once by opening the PNG at 1920×1080
and measuring the bounding box of the target code block in pixels, then converting:
`manim_x = (px - 960) / 120`, `manim_y = -(py - 540) / 120` (approximate,
calibrate in a draft render).

---

### 10.6 Proof / Lambda-Calculus Notation (MathTex, not CodePanel)

For **MANIM B** (Curry-Howard) and **MANIM C** (MLTT), the content is mathematical
proof notation, not IDE code. These should use `MathTex`, not `CodePanel`.

The natural-deduction proof tree is the same structure as the touying `nd-rule` helper
but in Manim:

```python
# manim_video/lib/nd_rule.py  — Manim equivalent of touying nd-rule helper

class NDRule(VGroup):
    """
    A natural-deduction inference rule with a horizontal bar.

    premises    : list of str (LaTeX)
    conclusion  : str (LaTeX)
    label       : str (LaTeX) or None — appears right of the bar in ACCENT colour
    """
    def __init__(self, premises: list, conclusion: str,
                 label: str = None, font_size: int = 36, **kwargs):
        super().__init__(**kwargs)
        prem_mobs = [MathTex(p, font_size=font_size) for p in premises]
        concl_mob = MathTex(conclusion, font_size=font_size)

        prem_row = VGroup(*prem_mobs).arrange(RIGHT, buff=0.4)
        bar_width = max(prem_row.width, concl_mob.width) + 0.3

        bar = Line(LEFT * bar_width/2, RIGHT * bar_width/2,
                   color=FG_DARK, stroke_width=1.2)
        if label:
            lbl = MathTex(label, font_size=font_size - 6, color=ACCENT)
            bar_with_label = VGroup(bar, lbl).arrange(RIGHT, buff=0.1)
        else:
            bar_with_label = bar

        rule = VGroup(prem_row, bar_with_label, concl_mob).arrange(DOWN, buff=0.15)
        self.add(rule)
        # Expose sub-components for per-part animation
        self.premises  = prem_mobs
        self.bar       = bar
        self.label_mob = lbl if label else None
        self.conclusion = concl_mob
```

**Usage in MANIM A (Gentzen ∨E):**

```python
ve_rule = NDRule(
    premises   = [r"A \vee B", r"[A] \to C", r"[B] \to C"],
    conclusion = r"C",
    label      = r"(\vee E)",
)
# Reveal premises first, then bar, then conclusion
self.play(AnimationGroup(
    *[FadeIn(p) for p in ve_rule.premises], lag_ratio=0.3))
self.play(Create(ve_rule.bar), FadeIn(ve_rule.label_mob))
self.play(FadeIn(ve_rule.conclusion, shift=DOWN * 0.1))
```

**The pull-out animation in MANIM B** uses these `NDRule` components directly:

```python
# The ∨E node in the full proof tree — grab it as a sub-VGroup
ve_application = VGroup(ve_rule.bar, ve_rule.label_mob, ve_rule.conclusion)

# The case(...) term from the code side — built with MathTex
case_term = MathTex(
    r"\text{case}(x,\ \lambda a.\,f(a),\ \lambda b.\,g(b))",
    font_size=32,
)

# Surround both in gold boxes, then lift
ve_box   = SurroundingRectangle(ve_application, color=ACCENT, buff=0.12, corner_radius=0.08)
case_box = SurroundingRectangle(case_term,      color=ACCENT, buff=0.12, corner_radius=0.08)

self.play(Create(ve_box), Create(case_box))

# Lift the highlighted fragments
self.play(
    VGroup(ve_application, ve_box).animate.move_to(UP * 2.2 + LEFT * 3.0),
    VGroup(case_term, case_box).animate.move_to(UP * 2.2 + RIGHT * 3.0),
    # Remaining proof tree dims and falls
    proof_tree_rest.animate.set_opacity(0.08).shift(DOWN * 4.5),
    lambda_term_rest.animate.set_opacity(0.08).shift(DOWN * 4.5),
    run_time=3.5,
    rate_func=rate_functions.ease_out_cubic,
)
```

The `proof_tree_rest` is a `VGroup` of everything in the proof tree **except**
`ve_application`. Build it by `.remove(ve_application)` after the tree is constructed,
or track it separately during construction.

---

### 10.7 Demo Output — `TerminalPane`

Used for the Stage 6 linearity demo: show the Idris 2 compiler error when `finish`
is omitted. The terminal is a darker panel than the code pane, monospaced, with
coloured output lines.

```python
# manim_video/lib/terminal_pane.py

TERMINAL_BG = "#0d0e13"   # darker than CODE_BG for visual separation

class TerminalPane(VGroup):
    """
    A terminal-style output panel.
    lines: list of (text, color) tuples.
    """
    def __init__(self, lines: list, width=7.0, font_size=18, **kwargs):
        super().__init__(**kwargs)
        line_mobs = [
            Text(text, font=FONT, font_size=font_size, color=color)
            for text, color in lines
        ]
        content = VGroup(*line_mobs).arrange(DOWN, buff=0.1, aligned_edge=LEFT)
        pad = 0.25
        bg = Rectangle(
            width=width,
            height=content.height + 2 * pad,
            fill_color=TERMINAL_BG, fill_opacity=1,
            stroke_color=GUTTER_FG, stroke_width=0.8,
        )
        content.move_to(bg)
        self.add(bg, content)
        self.line_mobs = line_mobs

    def reveal_line_by_line(self, lag=0.4) -> Animation:
        """Reveal each output line with a pause between them."""
        return LaggedStart(
            *[FadeIn(l) for l in self.line_mobs],
            lag_ratio=lag,
        )
```

**Idris 2 linearity error — usage:**

```python
terminal = TerminalPane([
    ("$ idris2 --build payment.ipkg",                  CODE_DIM),
    ("Building ./build/exec/paymentdemo",               CODE_DEFAULT),
    ("  Compiling Main (Main.idr)",                     CODE_DEFAULT),
    ("",                                                CODE_DEFAULT),
    ("PaymentChannel.idr:47:5-47:11",                  BAD),
    ("  There are 0 uses of linear name `done`.",      BAD),
    ("  Suggestion: linearly bounded variables must",   CODE_DEFAULT),
    ("  be used exactly once.",                         CODE_DEFAULT),
], width=8.0)

self.play(FadeIn(terminal.bg))
self.play(terminal.reveal_line_by_line(lag=0.5))
```

---

### 10.8 The Hover-Pop (for S32, MLTT Running as Programs)

Slide 33 (`29-mltt-running.typ`) shows Π and Σ rules side by side with actual
Idris code. The code-pane component already supports a `hover` parameter. For the
video, animate the hover-pop to make the Π-elimination firing visible:

**Approach**: Use T2 (two PNG variants):
1. `s30_clean.png` — export `29-mltt-running.typ` without hover
2. `s30_hover.png` — export with `hover: (3, 18, "SessionType — computed from snap.level")`

In Manim:
```python
clean = ImageMobject("slide_pngs/s30_clean.png").set_height(8)
hover = ImageMobject("slide_pngs/s30_hover.png").set_height(8)
self.add(clean)
self.wait(4.0)                               # narrator says "protocolFromSnapshot…"
self.play(FadeTransform(clean, hover, run_time=0.8))
self.wait(3.0)
```

No Manim code reconstruction needed — the touying component handles the hover
rendering perfectly; we just cross-dissolve between the two exports.

---

### 10.9 Font Installation for the Render Environment

JetBrains Mono is required in the Manim render environment. Add to `render.sh`:

```bash
#!/usr/bin/env bash
# render.sh — check font, then render

if ! fc-list | grep -qi "JetBrains Mono"; then
  echo "⚠  JetBrains Mono not found — installing…"
  sudo apt-get install -y fonts-jetbrains-mono 2>/dev/null || \
  pip install --quiet manim[jupyterlab] && \
  echo "  Please install JetBrains Mono manually if apt failed."
  fc-cache -f
fi

QUALITY="${1:-m}"   # l=480p, m=720p, h=1080p, k=4K
SCENE="${2:-}"

if [ -n "$SCENE" ]; then
  manim -pq"$QUALITY" main.py "$SCENE"
else
  manim -pq"$QUALITY" main.py
fi
```

In the `CodePanel`, if JetBrains Mono is missing, Manim silently falls back to
DejaVu Sans Mono (the Manim bundled font). Character widths differ slightly —
always do a draft render with the actual font before committing to `char_width`
calibrations.

---

### 10.10 Syntax Highlighting Consistency Checklist

Before final render, verify:
- [ ] Keywords (`val`, `def`, `sealed`, `case`, `match`, `fun`, `type`, `let`) →
      `C_KEYWORD` (#D4A86A, warm gold)
- [ ] Type names (`RiskLevel`, `SessionType`, `Payment`, `String`, `Int`) →
      `C_TYPE` (#6FCFD8, steel blue)
- [ ] String literals (`"auto-approved-wrong"`, `"auth-"`) →
      `C_STRING` (#8DC07A, sage green)
- [ ] Numeric literals (`4500`, `1`) → `C_NUMBER` (#D4826A, coral)
- [ ] Comments → `C_COMMENT` (#7A7D70, desaturated olive)
- [ ] Function/method names (`authorize`, `fastPath`, `assessRisk`) →
      `C_FUNCTION` (#C8A84E, bright amber)
- [ ] Operators (`=>`, `=:=`, `->`, `**`, `::`) → `#89CCDF` (light cyan)
- [ ] Error-highlighted tokens → `BAD` (#C44F3E)
- [ ] Background panels → `CODE_BG` (#1a1d26)
- [ ] Diagnostic strips → `CODE_DIAG_BG` (#232634)
- [ ] All code fonts → `"JetBrains Mono"` (verify `fc-list | grep JetBrains`)

The goal: a code block rendered by `CodePanel` in Manim should be visually
indistinguishable from the same block rendered by `code-pane.typ` in touying.

---

## 11. Demo Integration — Running Programs, Live Edits, and Multi-File Navigation

The stage demos are **not** decorative code panels. They are three distinct types of
content, each requiring a different animation approach:

| Type | Examples | Treatment |
|------|----------|-----------|
| **A — Run and see bad output** | Stage 0 `node demo.js` | `TerminalPane` replay |
| **B — Live edit → compiler reacts** | Stage 3 delete, Stage 4 uncomment, Stage 6 linearity | `CodePanel` edit animation — the three key cinematic moments |
| **C — Multi-file navigation** | Stage 5a phantom/refined, Stage 5b duality, Stage 6 Π/Σ | `DemoNavigator` split panels with annotation arrows |

In every case, **no IDE chrome** appears — no file tree, no menu bar, no IntelliJ
decorations. Only the code, in clean `CodePanel` panels on the dark background.
The demo segments should feel like the mathematical animations, not screen recordings.

---

### 11.1 Type B — The Three Live-Edit Moments

These are the most important demo animations in the entire video. Each one is the
**practical payoff** of the abstract theory shown minutes earlier. The connection must
be made explicit in the animation.

---

#### B1 — Stage 3: Live Delete (S20, ~22:00)
*"That compile error IS Gentzen's ∨E."*

**What it proves**: OR-elimination requires a handler for every branch.
Missing the Medium case = failing to supply `[B]→C`. The compiler is running
the elimination rule.

**Scene**: `Stage4LiveDeleteScene` (~40s)

**Layout**: Split screen. Left third: the ∨E rule (smaller, from MANIM A, already
familiar). Right two-thirds: a `CodePanel` showing the `RiskDecision` switch.

```
┌─────────────────────────┬──────────────────────────────────────────────────┐
│  ∨E rule (familiar)     │  RiskDecision.java                               │
│                         │                                                  │
│  A∨B   [A]→C   [B]→C   │  switch (decision) {                             │
│  ─────────────────────  │    case Low    l -> "low-risk fast path";         │
│           C             │    case Medium m -> "medium-risk 3DS path";  ←   │
│                         │    case High   h -> "high-risk review path";      │
│                         │  }                                               │
└─────────────────────────┴──────────────────────────────────────────────────┘
```

Beat 1 (0–8s): Both panels appear. Arrow annotations connect:
- `A∨B` ↔ `RiskDecision` type  
- `[A]→C` ↔ `case Low ...`  
- `[B]→C` ↔ `case Medium ...` (gold highlight on both)  
- third case ↔ `case High ...`

Beat 2 (8–14s): The `case Medium m -> "medium-risk 3DS path";` line in the code
**deletes** — `FadeOut` with a brief cursor-blink beforehand. Simultaneously,
the `[B]→C` premise in the ∨E rule **dims to red** (BAD color) and the bar/conclusion
of the rule also dim, indicating the rule can no longer be applied.

Beat 3 (14–20s): The `DiagnosticStrip` appears beneath the code panel:
```
error  switch covers only 2 of 3 permitted subclasses of 'RiskDecision' — missing: Medium
```

A small label appears below the ∨E rule (dim red text):
```
[B]→C missing — rule cannot be applied
```

Beat 4 (20–32s): The missing case **types itself back in** (gold glow as the characters
appear). The ∨E rule restores (premises return to full opacity). The error strip
`FadeOut`. Caption at bottom:
```
"Exhaustive match IS ∨-elimination. The compiler runs the rule."
```

**Code used** (from `03-java-function-types-sealed/PaymentService.java`):
```java
return switch (risk) {
    case RiskDecision.Low    l -> fastPath(order, log);
    case RiskDecision.Medium m -> threeDsPath(order, log);
    case RiskDecision.High   h -> manualReviewPath(order, log);
};
```

**YAML beats**:
```yaml
stage3_live_delete:
  audio_offset_s: 22.5
  total_dur_s: 40.0
  beats:
    panels_appear:         { t: 0.0,  dur: 2.0 }
    arrows_appear:         { t: 2.5,  dur: 2.5 }
    medium_highlight:      { t: 5.5,  dur: 1.0 }
    cursor_blink:          { t: 8.0,  dur: 0.8 }
    line_deletes:          { t: 8.8,  dur: 0.6 }
    rule_dims:             { t: 8.8,  dur: 1.0 }   # simultaneous with delete
    error_strip_appears:   { t: 10.5, dur: 1.0 }
    rule_error_label:      { t: 11.5, dur: 0.8 }
    pause_on_error:        { t: 12.5, dur: 4.0 }
    line_types_back:       { t: 16.5, dur: 2.5 }
    rule_restores:         { t: 18.0, dur: 1.5 }
    error_fades:           { t: 19.5, dur: 0.8 }
    caption_appears:       { t: 21.0, dur: 2.0 }
    hold:                  { t: 23.0, dur: 17.0 }
```

---

#### B2 — Stage 4: Live Uncomment (S23, ~24:30)
*"The lifecycle ordering is now a type constraint."*

**What it proves**: Phantom typestate prevents out-of-order lifecycle calls by
making each state an incompatible type parameter.

**Scene**: `Stage5LiveUncommentScene` (~40s)

**Layout**: Three panels stacked vertically (or left/right for the key moment).

Top: The method signature family — a compact read-only display:
```
initiate(order)                        → Payment<Initiated>
authorizeAuto(Payment<Initiated>)      → Payment<Authorized>
capture(Payment<Authorized>)           → Payment<Captured>
```
Each arrow's right-hand type is highlighted with a coloured "phantom" badge:
`Initiated` in dim grey, `Authorized` in amber, `Captured` in green.

Bottom: `CodePanel` for the demo method body:
```java
Payment<Initiated>   init       = Payment.initiate(order);
Payment<Authorized>  authorized = Payment.authorizeAuto(init);
Payment<Captured>    captured   = Payment.capture(authorized);

// error: capture(Payment<Authorized>) cannot be applied to (Payment<Initiated>)
// Payment.capture(init);                    // ← UNCOMMENT
```

Beat 1 (0–10s): Signature family appears top. Type annotations highlighted:
`<Initiated>` → dim, `<Authorized>` → amber, `<Captured>` → green.
State machine flow arrows animate between them.

Beat 2 (10–18s): Code panel appears below. The three valid lifecycle lines appear.
Type annotations on `init`, `authorized`, `captured` match the colours in the signature family.

Beat 3 (18–24s): The comment prefix `// ` on `Payment.capture(init)` is
**removed** — a Backspace-like animation erasing the `//` characters. The line
becomes live code, its tokens properly coloured. The `init` identifier gets an
Initiated-coloured badge (dim grey).

Beat 4 (24–30s): `DiagnosticStrip` appears:
```
error  capture(Payment<Authorized>) cannot be applied to Payment<Initiated>
```
A red arrow appears from the error strip pointing to the `<Initiated>` badge on `init`,
and a gold arrow points to `<Authorized>` in the `capture` signature. The mismatch
is spatial and visual.

Beat 5 (30–38s): Re-comment the line (re-add `// `). Error disappears. Caption:
```
"Charlie's out-of-order state transition: now structurally impossible."
```

**YAML beats**:
```yaml
stage4_live_uncomment:
  audio_offset_s: 25.3
  total_dur_s: 40.0
  beats:
    signature_family_appear:    { t: 0.0,  dur: 2.5 }
    state_machine_flow:         { t: 3.0,  dur: 2.0 }
    code_panel_appear:          { t: 6.0,  dur: 2.5 }
    type_badges_appear:         { t: 9.0,  dur: 1.5 }
    comment_erases:             { t: 12.0, dur: 1.2 }
    live_code_colours:          { t: 13.2, dur: 0.5 }
    error_strip_appears:        { t: 14.5, dur: 1.0 }
    mismatch_arrows_appear:     { t: 15.5, dur: 1.5 }
    pause_on_error:             { t: 17.0, dur: 4.0 }
    recomment:                  { t: 21.0, dur: 0.8 }
    error_fades:                { t: 21.8, dur: 0.5 }
    caption_appears:            { t: 23.0, dur: 2.0 }
    hold:                       { t: 25.0, dur: 15.0 }
```

---

#### B3 — Stage 6: Linearity Demo (S31/S33, ~38:00)
*"Dropping a session without closing it is a compile error."*

**What it proves**: QTT multiplicity-1 means the channel is a linear resource —
every program that compiles must have consumed it exactly once.

**Scene**: `Stage7LinearityScene` (~30s)

**Layout**: Split. Left: short `CodePanel` showing the multiplicity annotation.
Right: `CodePanel` showing the `runScenario` function with `finish done`.

Left panel (`PaymentChannel.idr`):
```idris
send    : (1 ch : Session (Send a rest)) -> a -> ...
          ↑
         "consume exactly once"

-- Multiplicities:
--   0 = erased      1 = linear      ω = unrestricted
```
The `1` annotation is in gold. The comment line appears as a teaching label.

Right panel (`Main.idr` — simplified):
```idris
runScenario : IO ()
runScenario = do
  (client, server) <- openSession (protocolFromSnapshot snap n c)
  ...
  finish done     -- ← will be commented out
```

Beat 1 (0–8s): Both panels appear. The `1` annotation in the left panel pulses gold.
Arrow from `1 ch` to a label: `"use exactly once — the type checker counts it."`.

Beat 2 (8–14s): The `finish done` line gets a cursor. `-- ` is typed in front of it.
The line becomes a comment (colour shifts to C_COMMENT). Simultaneously, the `done`
binding earlier in the function briefly highlights gold, then turns red.

Beat 3 (14–22s): `TerminalPane` slides in below, showing the compiler output:
```
$ idris2 --build payment.ipkg
  Compiling Main (Main.idr)

Main.idr:47:5-47:11
  There are 0 uses of linear name `done`.
  Suggestion: linearly bounded variables must be used
  exactly once.
```
The error lines appear in red. The `0 uses` phrase highlights.

A label appears connected to the error: `"The type checker counted — 1 expected, 0 found."`.

Beat 4 (22–30s): Uncomment the line (reverse animation). Error disappears. Terminal
shows `Building ./build/exec/paymentdemo` completing. Caption:
```
"Not a code review issue. A compile error."
```

**YAML beats**:
```yaml
stage6_linearity:
  audio_offset_s: 38.5
  total_dur_s: 30.0
  beats:
    panels_appear:          { t: 0.0,  dur: 2.0 }
    multiplicity_arrow:     { t: 2.5,  dur: 1.5 }
    multiplicity_pulse:     { t: 4.5,  dur: 0.8 }
    comment_types_in:       { t: 7.0,  dur: 1.2 }
    done_dims_red:          { t: 8.0,  dur: 0.8 }
    terminal_slides_in:     { t: 10.0, dur: 1.0 }
    terminal_output_reveal: { t: 11.5, dur: 3.0 }
    zero_uses_highlight:    { t: 15.0, dur: 1.0 }
    error_label_appears:    { t: 16.5, dur: 1.0 }
    pause_on_error:         { t: 17.5, dur: 3.0 }
    uncomment:              { t: 20.5, dur: 0.8 }
    terminal_success:       { t: 21.3, dur: 1.5 }
    caption_appears:        { t: 23.0, dur: 1.5 }
    hold:                   { t: 24.5, dur: 5.5 }
```

---

### 11.2 Type A — Terminal Output Replay

Used for Stage 0 and for any stage where "running the program" is the point,
not editing it.

#### Stage 0 — `node demo.js` (S17, ~12:30)

The actual bad-demo terminal output from `00-js-untyped-payment/demo.js`:

```python
stage0_terminal_lines = [
    # section header for bad demo 1
    ("═" * 60,                                         CODE_DIM),
    ("  BAD DEMO — Capture Before Authorize",           BAD),
    ("═" * 60,                                         CODE_DIM),
    ("  [INFO]  capture(order) returned: {captureId: \"cap-undefined\"}",  CODE_DEFAULT),
    ("  [INFO]  capturedAmount is: undefined  ← wrong object shape",       BAD),
    ("  [INFO]  No error thrown. This 'succeeds' at runtime.",              CODE_DEFAULT),
    ("  > BUG: wrong shape, no error.",                                     BAD),
    ("═" * 60,                                         CODE_DIM),
    # blank
    ("",                                               CODE_DEFAULT),
    # section header for bad demo 2
    ("═" * 60,                                         CODE_DIM),
    ("  BAD DEMO — Medium-Risk Order Skips 3DS (Bob's bug)",               BAD),
    ("═" * 60,                                         CODE_DIM),
    ("  [INFO]  approvalNote: 'auto-approved-wrong'",                       BAD),
    ("  [INFO]  no challenge was completed",                                BAD),
    ("  > BUG: medium-risk authorized without 3DS.",                       BAD),
    ("═" * 60,                                         CODE_DIM),
]
```

Before the terminal: show a brief `CodePanel` with `buggyDemo_Skip3DS()` (the
5-line function showing the if/else over risk). Linger 2s, then `FadeOut`. Then
`TerminalPane` appears with the output typing in.

The good demos' output can be shown briefly as `CODE_DEFAULT` lines scrolling up,
then the BAD DEMO headers appear in `BAD` colour. The contrast is the point.

#### Stage 6 run — `./build/exec/paymentdemo` (S33, ~40:00)

Show 3 demo runs in sequence:
```
demo1 — Low-risk: protocolFromSnapshot snap = LowRefundProtocol
demo2 — Medium-risk: protocolFromSnapshot snap = MediumProtocol (3DS exchange visible)
demo3 — High-risk: protocolFromSnapshot snap = HighProtocol
```
The key line in each is the `protocolFromSnapshot snap :` output — this is the Π-type
actually running, not a pre-selected ADT branch. Highlight it in gold each time.

---

### 11.3 Type C — Multi-File Navigation

For demos that require moving between related source files, use a `DemoNavigator`
scene: two `CodePanel` instances, each with its own filename tab, laid side by side
or sequentially. Annotation arrows connect related pieces across files.

---

#### Stage 5a Navigation (S26, ~26:00–30:00)

**File 1: `Domain.scala`** — Refined types
```scala
type NonEmptyString = String :| MinLength[1]
type OrderId        = NonEmptyString
type CustomerId     = NonEmptyString
```
Animation: the `:|` operator gets a label: `"predicate lifted into the type"`.
Show `OrderId.of("")` returning `Left(...)` vs `"ord-001".refineUnsafe[...]`
compiling instantly.

**File 2: `Domain.scala`** — Phantom approval indexing
```scala
sealed trait Approval[+R <: Risk]
case object AutoApproved     extends Approval[LowRisk]
case object ThreeDSCompleted extends Approval[MediumRisk]

def authorize[R <: Risk](order: Order, approval: Approval[R])
    : Either[String, AuthorizedPayment[R]]
```
Animation: try substituting `AutoApproved` for `Approval[MediumRisk]` in the call.
Type parameter shows the mismatch: `Approval[LowRisk]` ≠ `Approval[MediumRisk]`.

**Cross-file annotation**: an arrow from the `R` type parameter in `authorize` to the
`R` in `Approval[R]` in the sealed trait, showing the connection.

---

#### Stage 5b Navigation (S27, ~30:00–31:00) — see MANIM F

Additionally, animate the `server_swap` moment mentioned in the speaker notes:
```scala
// Before: server using the correct handler
case ProtocolVariant.LowRefund => serverLowRisk(...)

// Live swap: change to wrong handler
case ProtocolVariant.LowRefund => serverMediumRisk(...)  // ← swapped
```
DiagnosticStrip: `type mismatch — found: Channel[Dual[MediumRiskProtocol]], required: Channel[Dual[LowRiskProtocol]]`

This shows that even with the ProtocolVariant bridge ADT, the compiler enforces
that the handler used matches the protocol shape.

---

#### Stage 6 Multi-File Navigation (S32, ~35:30–36:30)

This is the MLTT rules running as programs moment. Show the theory and the implementation
side by side, explicitly mapping rule to code.

**Layout**: Two columns.

Left column: The two inference rules (from MANIM C — smaller versions):
```
Π-elimination:    f : (Πx:A). B(x)    a : A
                  ─────────────────────────────
                          f(a) : B(a)

Σ-introduction:   a : A     b : B(a)
                  ──────────────────
                  (a, b) : (Σx:A). B(x)
```

Right column: `CodePanel` showing the matching Idris signatures:

**Panel 1** (`PaymentRules.idr`) — Π-elimination in code:
```idris
protocolFromSnapshot : RiskSnapshot -> SessionType
-- applied: openSession (protocolFromSnapshot snapshot n c)
```
Animation: an arrow from `B(a)` in the rule's conclusion to `SessionType`
annotated with "computed from runtime value of `snapshot`".

**Panel 2** (`PaymentDomain.idr`) — Σ-introduction in code:
```idris
assessOrder : Order n c -> (lvl ** Assessment lvl n c)
--                          ↑           ↑
--                     value lvl    proof depends on lvl
```
Animation: an arrow from `(a, b)` in the Σ rule to `(lvl ** Assessment lvl n c)`,
annotated: `"lvl = the value; Assessment lvl = the proof parameterised by lvl"`.

The `**` operator in Idris's Σ-type syntax gets a gloss: `"dependent pair"`.

---

### 11.4 Complete Demo Scene Map

Add these scenes to the file structure:

```
manim_video/scenes/
  ...
  15_stage0_terminal.py        ← TerminalPane for Stage 0 bad demos
  16_stage1_private_ctor.py    ← CodePanel: private constructor squiggle
  17_stage3_live_delete.py     ← B1: THE live delete with split ∨E/switch
  18_stage4_live_uncomment.py  ← B2: Live uncomment + phantom typestate mismatch arrows
  19_stage5a_navigation.py     ← C: NonEmptyString + phantom approval multi-file
  20_stage5b_server_swap.py    ← C: Server handler swap compile error
  21_stage6_pi_sigma.py        ← C: Rules split-panel (MLTT running)
  22_stage6_linearity.py       ← B3: Linearity live comment-out
  23_stage6_run.py             ← TerminalPane for Stage 6 paymentdemo output
```

Updated priority order:
1. `17_stage3_live_delete.py` — most important demo in the whole talk; planned in §11.1-B1
2. `22_stage6_linearity.py` — closes the talk's arc
3. `18_stage4_live_uncomment.py`
4. `15_stage0_terminal.py` — needs the actual output hardcoded (verified above by running `node demo.js`)
5. `21_stage6_pi_sigma.py`
6. `19_stage5a_navigation.py`
7. `23_stage6_run.py`
8. `16_stage1_private_ctor.py`
9. `20_stage5b_server_swap.py`

---

### 11.5 Connecting Theory to Demo — The Recurring Animation Pattern

Every live-edit moment should explicitly link back to the abstract theory:

| Demo moment | Theory it instantiates | Visual connector |
|-------------|------------------------|------------------|
| Stage 3 delete Medium case | Gentzen ∨E — `[B]→C` missing | Split panel with ∨E rule left; arrows |
| Stage 4 uncomment capture | Phantom typestate — incompatible `<S>` parameters | Type badges + mismatch arrows |
| Stage 6 comment finish | QTT multiplicity-1 — zero uses of linear name | `1` annotation glows, count label |

These three visual connectors — arrows between a rule and its code instantiation —
are a recurring motif in the video that rewards viewers who followed the theory arc.

---

### 11.6 Source Code References for All Demo Scenes

All code shown in demo scenes comes verbatim from the actual source files. Never
paraphrase. Use the exact function bodies and exact error messages.

| Scene | File | Function / excerpt |
|-------|------|--------------------|
| Stage 0 terminal | `00-js-untyped-payment/demo.js` | `buggyDemo_CaptureBeforeAuthorize`, `buggyDemo_Skip3DS` outputs |
| Stage 1 private ctor | `01-java-simple-types/Authorization.java` | Constructor, `from()` smart constructor |
| Stage 3 live delete | `03-java-function-types-sealed/PaymentService.java` L:59 | `switch(risk)` block |
| Stage 4 live uncomment | `04-java-advanced-generics-typestate/Demo.java` L:166-176 | `demo4_TypestateCompileErrors` |
| Stage 5a phantom | `05-scala3-payment/src/main/scala/payment/Domain.scala` | `Approval[+R <: Risk]`, `authorize[R]` |
| Stage 5a refined | `05-scala3-payment/src/main/scala/payment/Domain.scala` | `type NonEmptyString` |
| Stage 5b server swap | `05-scala3-payment/src/main/scala/demos/PaymentDemo.scala` | `demo2` server handler |
| Stage 6 Π rule | `06-idris2-payment/src/PaymentRules.idr` | `protocolFromSnapshot` |
| Stage 6 Σ rule | `06-idris2-payment/src/PaymentDomain.idr` | `assessOrder` |
| Stage 6 linearity | `06-idris2-payment/src/Main.idr` | `finish done` line |
| Stage 6 run | `06-idris2-payment/src/Main.idr` | `runOrderScenario` outputs |

---

## 12. Narrative and Design Revision — Full Pass

> **This section supersedes §3 (MANIM A, B, E storyboards), §11.1 (B1), and §1 (S7/S8/S35/S38 treatments). All other sections remain valid.**
>
> The first-pass plan was written as an inventory. This pass makes it a narrative.

---

### 12.1 The Core Redundancy Problem — ∨E Told Three Times

The plan as written presents the same idea — OR-elimination = exhaustive match = the rule you can't skip a branch of — in three successive scenes:

| Scene | What it does |
|-------|-------------|
| **MANIM A** (S10, 9:05) | Introduces ∨E, shows Scala match, ends: "Exhaustive match IS ∨-elimination" with `≡` gold boxes |
| **MANIM B** (S11, 9:35) | Shows a natural-deduction proof tree + lambda term, highlights the ∨E node + case expression, pulls them up, reveals `≅` |
| **B1 / Stage 3 demo** (S20, 22:00) | Split panel: ∨E rule on the left, Java switch on the right, delete Medium case, rule dims |

MANIM B then adds the caption "Proof = Program · Type = Proposition" — which is a genuinely new idea — but buries the lede because the vehicle (another ∨E demonstration) makes it look like a repetition of MANIM A rather than an elevation above it.

And B1 re-teaches ∨E a third time, at minute 22, to an audience that absorbed it at minute 9. By then it's patronizing.

**The fix requires understanding what each scene is *for*:**

- **MANIM A** = *seed*: introduce the rules cleanly; establish that ∨ and its code form are structurally identical; end with the observation hanging in the air, not concluded
- **MANIM B** = *generalization*: the parallel just seen for ∨E is one instance of a deep isomorphism running across all of logic; show TWO correspondences, pull both up simultaneously, reveal the ≅ as the unifying insight
- **Stage 3 demo** = *payoff callback*: the audience already understands ∨E; the demo is a clean practical confrontation with no theory re-explanation; the callback is a small annotation, not a lecture

And MANIM E (§3, "Bob's Missing Branch + Sum-Type Fix") is removed — it duplicates both the S3 incident slide (Bob's bug already established) and B1 (the Stage 3 demo). The practical payoff belongs in the demo scene, not a separate conceptual animation.

---

### 12.2 Revised: MANIM A — Gentzen OR Rules (S10)

**Revised purpose**: Seed, not conclusion. Introduce the rules. Show the structural
parallel. End with the observation in the air — do *not* close with the equivalence
symbol. The `≡` would be premature; the `≅` in MANIM B earns it properly.

**Revised duration**: 28s (slightly shorter — we're not trying to conclude anything).

#### Phase 1 — Introduction rules: building A∨B (0–8s)

Dark background. Two columns (logic left, code right).

Left: the two introduction rules appear one at a time, top to bottom:
```
  A          B
──────  ∨I₁    ──────  ∨I₂
 A∨B          A∨B
```
Right: as each rule appears, its code counterpart slides in beside it:
```scala
Left(a)    // ∨I₁: inject left
Right(b)   // ∨I₂: inject right
```
The one-to-one appearance (rule, then code, then next rule, then code) makes the
parallel feel discovered rather than stated.

#### Phase 2 — Elimination rule: using A∨B (8–20s)

Left: the ∨E rule assembles — premises left-to-right, bar draws itself, label `(∨E)`
in amber, conclusion drops:
```
A∨B    [A]→C    [B]→C
──────────────────────  (∨E)
           C
```
Right: the full match block appears:
```scala
x match {
  case Left(a)  => useA(a)   // [A]→C
  case Right(b) => useB(b)   // [B]→C
}
```
The in-code comments `// [A]→C` and `// [B]→C` are in dim amber — they name the
premises explicitly without needing arrows.

#### Phase 3 — The gap (20–28s)

The `case Right(b) => ...` line dims to a near-invisible grey. A single question
appears below, centred, in amber:
```
What happens when a branch is missing?
```
Hold 3s. Fade to black. No answer given — MANIM A has seeded the question;
MANIM B (one slide away) will answer it by revealing the isomorphism's consequences,
and the Stage 3 demo (thirteen minutes later) will demonstrate it in running code.

**What's removed from the original**: Phase 4 (the gold highlight boxes, the `≡`
symbol, the "Exhaustive match IS ∨-elimination" caption). All three belonged in
MANIM B, not here.

**Revised YAML beats**:
```yaml
gentzen_or:
  audio_offset_s: 9.05
  total_dur_s: 28.0
  beats:
    vi1_rule_appear:     { t: 0.0,  dur: 1.5 }
    vi1_code_appear:     { t: 1.8,  dur: 1.0 }
    vi2_rule_appear:     { t: 3.2,  dur: 1.5 }
    vi2_code_appear:     { t: 5.0,  dur: 1.0 }
    ve_rule_appear:      { t: 7.5,  dur: 3.5 }   # bar draws itself
    ve_match_appear:     { t: 9.5,  dur: 2.5 }
    right_case_dims:     { t: 18.0, dur: 1.5 }
    question_appears:    { t: 20.5, dur: 1.5 }
    hold:                { t: 22.0, dur: 4.0 }
    fade_to_black:       { t: 26.0, dur: 2.0 }
```

---

### 12.3 Revised: MANIM B — Curry-Howard Isomorphism (S11 beat 3)

**Revised purpose**: Generalization. MANIM A showed ONE parallel (∨ = sealed/match).
MANIM B shows that this was not a lucky coincidence but one instance of a universal
structural correspondence. It answers the question MANIM A left open — and in doing
so reveals something much larger than the answer to "what happens when a branch is
missing."

**Revised duration**: 30s (slightly longer — this is the conceptual peak).

The change from the original: the proof tree + lambda term on the left/right are
now *richer* — they contain three correspondences, not one. ∨E is still the bridge
(it's the one the audience just saw), but the animation reveals that the isomorphism
extends to function types (`→`) and product types (`∧`) as well. The ≅ therefore
feels like a discovery, not a relabelling of what MANIM A already showed.

#### Setting (0–8s): Two worlds, larger than before

Left half — a natural-deduction proof. The proof uses three connectives:
```
     [A]¹               [B]²
  ────────  →E    ────────────  →E
   f a : C           g b : C
A∨B     f : A→C     g : B→C
────────────────────────────────  ∨E (¹,²)
              C
```
(A function application per branch, leading into the ∨E application — three rules
in one tree: →E twice + ∨E once.)

Right half — the corresponding program:
```
def handle(
  x : A|B,
  f : A => C,
  g : B => C
): C = x match {
  case Left(a)  => f(a)   // f a : C
  case Right(b) => g(b)   // g b : C
}
```
Again three constructs: two function calls (`f(a)`, `g(b)`) and the match.

Labels: `LOGIC` dim amber top-left, `PROGRAMS` dim amber top-right.

#### Phase 2 — Highlight: three correspondences at once (8–14s)

Rather than a single gold box, three pairs of amber connecting lines appear
simultaneously — one for each rule/construct pair:

1. `→E` (left) ↔ `f(a)` (right) — a short horizontal amber arc
2. `→E` (left) ↔ `g(b)` (right) — a short horizontal amber arc  
3. `∨E` (left) ↔ `match { ... }` (right) — a larger amber arc

All three arcs appear at once, in 1.5s. The effect is a web of connections — not
a single isolated parallel but a structural isomorphism running through the entire
example.

#### Phase 3 — The pull-out (14–21s)

The entire left proof tree and the entire right program are what get pulled up —
NOT just the ∨E fragments. The insight has changed: it's not "this one rule maps
to this one construct." It is "the *whole proof* maps to the *whole program*."

The three connecting arcs hold as both sides lift. What falls away is the labels
(`LOGIC`, `PROGRAMS`) and the explanatory comments.

The proof tree settles upper-left. The program settles upper-right. They are smaller
now — the full content, compressed and elevated.

#### Phase 4 — Isomorphism reveal (21–30s)

The `≅` appears between them at large size. The three arcs that connected the pairs
*converge* into the ≅ symbol as it materialises — the three lines merge and resolve
into the symbol.

Below the ≅, three lines appear in small amber mono, one at a time (~0.5s apart):
```
Type  =  Proposition
Program  =  Proof
Running  =  Simplifying the proof
```
The third line, "Running = Simplifying the proof," is the one that has no code
analogue yet visible — it is the *surprise*. The compiler's type checking is
*proving*; evaluation is *proof reduction*. Let it land.

Hold 3s. Fade to MANIM C.

**Why this is better**: The audience has not seen this proof tree before — it is
genuinely new visual content. The ∨E connection is familiar (from 25 seconds ago),
but its role as one instance in a larger picture is new. The answer to MANIM A's
hanging question ("what happens when a branch is missing?") is answered by
implication: missing a branch means failing to complete the proof. The ≅ makes
that feel cosmic rather than merely mechanical.

**Revised YAML beats**:
```yaml
curry_howard:
  audio_offset_s: 9.55
  total_dur_s: 30.0
  beats:
    logic_tree_appear:    { t: 0.0,  dur: 3.0 }
    program_appear:       { t: 1.5,  dur: 3.0 }
    labels_appear:        { t: 4.5,  dur: 1.0 }
    three_arcs_appear:    { t: 6.5,  dur: 1.5 }   # all three simultaneously
    arc_pulse:            { t: 8.2,  dur: 0.6 }
    lift_both_sides:      { t: 10.0, dur: 4.0 }   # whole trees, not fragments
    arcs_converge:        { t: 13.0, dur: 1.5 }   # arcs follow into ≅ position
    iso_appear:           { t: 14.5, dur: 1.5 }
    line1_appear:         { t: 17.0, dur: 0.8 }   # "Type = Proposition"
    line2_appear:         { t: 18.0, dur: 0.8 }   # "Program = Proof"
    line3_appear:         { t: 19.0, dur: 0.8 }   # "Running = Simplifying" ← the surprise
    hold:                 { t: 20.5, dur: 8.0 }
    fade_out:             { t: 28.5, dur: 1.5 }

  easing:
    lift:      "ease_out_cubic"
    fall_away: "ease_in_quad"
    iso:       "ease_out_back"
```

---

### 12.4 Revised: MANIM E — Removed

**MANIM E** ("Bob's Missing Branch + Sum-Type Fix") is removed from the plan.

Reasons:
1. Bob's if/else is already established at S3 (incident slide, minute 2). Re-showing
   it at minute 22 as a conceptual animation is redundant.
2. The Java → Scala code transition (if/else → sealed switch) belongs in the Stage 3
   demo scene, not a separate conceptual animation.
3. The sealed switch + exhaustive match is the subject of MANIM A. A second animation
   of the same mechanism adds nothing.

The Stage 3 demo scene (B1, §11.1) is the single animation for Stage 3. It is revised
next.

---

### 12.5 Revised: Stage 3 Demo — Clean Code, Brief Callback (§11.1-B1)

**Revised purpose**: A clean, punchy demonstration. No theory re-explanation. No
split panel. No ∨E rule on screen. At minute 22, the audience knows what ∨E means.

**Revised scene**: `Stage4SealedDeleteScene` (~25s)

The scene shows one thing: the sealed switch compiles, then breaks, then heals.

#### Phase 1 — The sealed hierarchy (0–6s)
Two-panel. Left: a small `CodePanel` showing just the sealed declaration:
```java
sealed interface RiskDecision
    permits Low, Medium, High {}
```
Right: the switch, all three branches present:
```java
return switch (risk) {
  case Low    l -> fastPath(order, log);
  case Medium m -> threeDsPath(order, log);
  case High   h -> manualReviewPath(order, log);
};
```
A tiny green ✓ in the corner: "compiles."

#### Phase 2 — Delete Medium (6–12s)
Cursor appears at the start of `case Medium m -> ...`. The line blinks once (cursor
effect). It deletes — `FadeOut(line, run_time=0.4)`.

The `DiagnosticStrip` slides up from beneath:
```
error  switch covers only 2 of 3 permitted subclasses of 'RiskDecision' — missing: Medium
```
A small amber annotation appears to the right of the error strip — not a full diagram,
just notation: `(∨E)` in small amber text, with a tiny connector line pointing at the
"missing: Medium" phrase. One line below it: `"[Medium]→result missing"`. This is a
footnote reference, not a lecture.

#### Phase 3 — Heal (12–20s)
The missing line types itself back in (`type_in_line`), gold glow. Error strip fades.
The green ✓ returns.

Caption at bottom:
```
"Bob's silent fall-through: now structurally impossible."
```

Brief echo: the "BOB" incident badge (see §12.7) flashes gold, a ✓ ticks through it.

Duration: 25s total. **What's removed**: the split panel with the ∨E rule and the
six annotation arrows. Those were from a different stage of the narrative.

**Revised YAML beats**:
```yaml
stage3_sealed_delete:
  audio_offset_s: 22.5
  total_dur_s: 25.0
  beats:
    sealed_decl_appear:   { t: 0.0,  dur: 1.5 }
    switch_appear:        { t: 1.8,  dur: 2.0 }
    green_check_appear:   { t: 4.0,  dur: 0.5 }
    cursor_blink:         { t: 5.5,  dur: 1.0 }
    line_deletes:         { t: 6.5,  dur: 0.4 }
    error_strip_slides:   { t: 7.0,  dur: 0.8 }
    ve_callback_appears:  { t: 8.5,  dur: 1.0 }   # small "(∨E)" footnote
    pause_on_error:       { t: 9.5,  dur: 2.5 }
    line_types_back:      { t: 12.0, dur: 2.0 }
    error_fades:          { t: 13.5, dur: 0.8 }
    check_returns:        { t: 14.5, dur: 0.5 }
    caption_appears:      { t: 15.5, dur: 1.5 }
    bob_badge_flash:      { t: 17.5, dur: 1.5 }
    hold:                 { t: 19.0, dur: 6.0 }
```

---

### 12.6 Revised: Theory Section Visual Variety (S7, S8)

The theory slides (S7 Toolkit, S8 Crisis) were assigned "beat-grid reveal" and
"quadrant reveal" — which means the video has nearly three minutes (5:30–8:30)
of static text appearing on a light background. For a recorded video that is this
dense to begin with, this is a significant drag.

#### S7 — Historical Timeline (replacing beat-grid fade-in)

Treat as a proper animation scene rather than a slide-PNG. Four entries spanning
2300 years deserve spatial staging.

**Scene**: A vertical timeline on the left edge. Year markers appear as small amber
dots. Each entry slides in from the right as a card, anchoring to its year dot.
Previous cards dim slightly (but stay legible) as the next appears.

Visual: the timeline is a vertical amber line. Aristotle's dot is at the top (oldest,
BCE), then down to Leibniz, Boole/DeMorgan, Frege et al. The card for each is 60%
of screen width, appearing in a smooth LEFT-slide. The year in amber mono, the name
in large light text, the description in smaller dim text.

Key effect: by the time all four are visible, the timeline looks like an archaeological
section — deep time rendered spatially. The line below each dim card reads like strata.

Duration: matches the 90s segment. Triggered at 5:30. Use the same beat-grid timing
from `beats.yaml:toolkit_timeline`.

This is **a new scene class**: `HistoricalTimelineScene`. It does not require the
slide PNG at all.

#### S8 — Russell's Paradox Flash (supplementing slide PNG)

Use T2 (slide PNG base + Manim overlay). The slide PNG appears first. Then, over
the Russell quadrant, a brief 4-second animation plays as an overlay:

A small white circle labelled `S` appears. Inside it, via an arrow, another small
circle also labelled `S`. An arrow from the inner circle points back to the outer
circle — a loop. After 1.5s: the loop flashes red, a small explosion effect
(circle expands to 0 opacity). Two fragments fly outward: one lands in the left
column (Russell, 1901) and is labelled `⊥ (inconsistency)`; the other lands in
the right column and is labelled `Types (the fix)`.

Total additional animation: 4s. Uses `Overlay-on-PNG` pattern (§10.5).

This is not a distraction — the speaker notes explicitly say "Russell found a fatal
flaw" and the paradox is the opening beat of S8. The visual concretises an abstract
idea that would otherwise require 10 seconds of explanation.

---

### 12.7 New Design Element: Incident Badge Tracking Thread

A recurring micro-animation that runs through the whole 45 minutes, creating a
narrative thread from the opening promise to the final resolution.

**The badges**: Four small rounded-rectangle chips, one per incident:
```
 ALICE   BOB   CHARLIE   DANIELLE
```
Each is amber-outlined with dim text. They appear at a fixed position in the
lower-right corner whenever relevant.

**Three states**: open (amber outline, dim text), resolving (brief gold flash),
closed (bright gold outline + `✓`).

**Timeline of appearances**:

| When | Badge event |
|------|-------------|
| S2–S5 (incidents) | Each badge appears in OPEN state as its incident is introduced |
| S6 (pattern) | All four badges briefly array together in the lower-right corner, all OPEN. Establishes them as a tracking set. |
| S21 (Stage 3 payoff) | BOB badge transitions open→closed: gold pulse, `✓` animates in |
| S21 | ALICE badge: note opens silently (dim) — "boundary partially closed; Stage 5 finalises it" |
| S24 (Stage 4 payoff) | CHARLIE badge transitions open→closed |
| S29 (Stage 5 payoff) | ALICE badge resolves closed; DANIELLE badge resolves closed (both at once — Stage 5 closes both) |
| S33 (Stage 6 payoff) | No new badge closes — Stage 6 improves mechanism, not scope |
| MANIM G (The Climb) | All four reappear in their closed state in the table summary phase |
| S38 (close) | All four badges appear briefly as echoes while names are spoken |

**Implementation**: The badges are a `PersistentOverlay` helper — a tiny `VGroup`
that can be added to any scene with `.show_badge(name, state)`. Not a full scene.
Add to the `lib/` directory and import per-scene as needed.

This thread costs little per-scene (a 0.5s animation for each badge transition)
but gives the video its narrative spine. The four bugs introduced at the opening
become the four promises fulfilled by the end.

---

### 12.8 Revised: MANIM D Lambda Cube — as a Talk Map

Add stage labels to the axis build-up. The lambda cube is not just an abstract
type-theory diagram — for this talk, it's a map of the journey.

**Revised Phase 2** (axis 1 — generics):
As the axis grows, a dim label fades in beside it:
`"Stages 2–4 · generics, parametricity"`

**Revised Phase 3** (axis 2 — type operators):
`"Stages 5–6 · type-level computation, session types"`

**Revised Phase 4** (cube face):
When the left face fills (dim amber glow), a small dotted path traces from the
origin to the face's far corner. Label: `"Java ceiling"` in small BAD colour near
the corner. This maps directly to S25 (the Java ceiling slide) — the face IS the
boundary the talk discussed.

**Revised Phase 5** (axis 3 — dependent types):
`"Stage 6 · types on values"` — appears brighter, as before, but now with the
"BAD barrier" face dimming and the new axis extending beyond it.

**New Phase 6** (10s added, total 55s): A dotted path animates — tracing the talk's
journey from origin (Stage 0) → up axis 1 (Stage 2) → up axis 2 (Stage 4/6) →
out axis 3 (Stage 6). The path is a thin bright line that follows the vertices of
the cube, leaving a glow trail. Final position: the Idris 2 vertex.

Caption: `"Every axis is a qualitative leap. The third is the frontier."`

This makes the cube a RETROSPECTIVE MAP (viewers who've absorbed the talk will
recognise the path) rather than only a prospective diagram. It's shown at the end
of the theory section (minute 11) but already contains the whole talk's arc as a
miniature.

---

### 12.9 Revised: S35 Agentic — Brief Animation (replacing flat fade-in)

The agentic slide is one of the most commercially timely points of the talk. It
deserves 8 seconds of animation.

**Scene**: `AgenticOverlayScene` — uses T2 (PNG base + overlay).

At beat 0: the slide PNG fades in.

At beat 4 (narrator: "Code is now being generated faster than humans can review it"):
A small `CodePanel` appears in the upper-right corner — narrow (2.5 units wide),
unlabelled. Lines of code appear in it rapidly, one per 0.08s — too fast to read,
simulating AI generation speed. About 12 lines appear in 1 second.

At beat 5: A scan line sweeps downward through the code panel. As it passes each
line, a small green `✓` appears to its left.

At beat 6: One line glows amber (a type-related line, e.g. `authorize[LowRisk](...)`).
The scan line hesitates on it, shows `✓`. If it had been a type error, it would show
a red `✗` — but it doesn't, because the type is correct.

At beat 7: The fast-generated code panel fades. Stays on the main slide.

This is 8 seconds of content that makes the "compiler does not care who wrote it"
claim feel concrete rather than asserted.

**YAML beats**:
```yaml
agentic_overlay:
  audio_offset_s: 42.0
  beats:
    slide_appears:        { t: 0.0,  dur: 1.5 }
    code_panel_appears:   { t: 4.0,  dur: 0.3 }
    lines_generate:       { t: 4.3,  dur: 1.0 }   # 12 lines, rapid
    scan_sweep:           { t: 5.5,  dur: 1.2 }
    key_line_holds:       { t: 6.7,  dur: 0.8 }
    panel_fades:          { t: 7.5,  dur: 0.8 }
```

---

### 12.10 Revised: S38 Close — Ghost Echoes

The close is currently "simple fade-in." The speaker's closing paragraph explicitly
names all four incidents — Alice, Bob, Charlie, Danielle — tracing the arc back to
the opening. The video should make this feel like a **resolution**, not a summary.

**Scene**: `CloseEchoScene` — uses T2 (PNG base + overlay).

As each name is spoken, the original incident's bug code briefly appears as a
ghost in the background: very dim (opacity 0.08), in the touying code-pane style,
positioned in the upper-left corner of the screen. It lingers 2s, then dissolves.
The four ghosts appear and dissolve in sequence, one per ~8s of the closing.

- "Alice" spoken (~43:35) → ghost of `"4500" + "1500" = "45001500"` appears top-left, dims out
- "Bob" spoken (~43:50) → ghost of `if (risk != HIGH) { return fastPath(order); }` appears, dims
- "Charlie" spoken (~44:05) → ghost of `paymentRail.execute(ref); // state never checked`, dims
- "Danielle" spoken (~44:20) → ghost of `server.receive(); // FinalConfirmation — client hangs`, dims

By the time "Thank you" appears, the screen is clean. The ghosts are echoes —
not reminders but acknowledgements. The bugs have been named and understood and,
finally, made impossible.

This adds four 2s overlay animations to a scene that would otherwise be 90s of
a static slide. The effect is worth the implementation cost.

---

### 12.11 Revised Scene Count and Implementation Priority

**Revised animation scene list** (§5 file structure updated):

```
manim_video/scenes/
  ── Theory arc ──────────────────────────────────────────────────────────
  05_historical_timeline.py    ← NEW: replaces S7 slide-PNG (§12.6)
  05b_russell_flash.py         ← NEW: S8 overlay (§12.6)
  06_gentzen_or.py             ← REVISED: ends with question, no ≡ (§12.2)
  07_curry_howard.py           ← REVISED: two correspondences + arcs converge (§12.3)
  08_mltt.py                   ← unchanged
  09_lambda_cube.py            ← REVISED: stage labels + journey path (§12.8)
  ── Incident arc ────────────────────────────────────────────────────────
  10_incident_badges.py        ← NEW: PersistentOverlay for badge tracking (§12.7)
  ── Demo arc ────────────────────────────────────────────────────────────
  15_stage0_terminal.py        ← unchanged
  16_stage1_private_ctor.py    ← unchanged
  17_stage3_sealed_delete.py   ← REVISED: no split panel, brief ∨E callback (§12.5)
  18_stage4_live_uncomment.py  ← unchanged
  19_stage5a_navigation.py     ← unchanged
  20_stage5b_server_swap.py    ← unchanged
  21_stage6_pi_sigma.py        ← unchanged
  22_stage6_linearity.py       ← unchanged
  23_stage6_run.py             ← unchanged
  ── Resolution arc ──────────────────────────────────────────────────────
  12_climb.py                  ← minor: badge callbacks from §12.7
  13_agentic_overlay.py        ← NEW: code-generation animation (§12.9)
  14_close_echo.py             ← NEW: ghost code overlays (§12.10)
  ── Removed ─────────────────────────────────────────────────────────────
  # 10_sum_type_payoff.py      ← REMOVED (was MANIM E) — see §12.4
```

**Revised implementation priority** (highest narrative value first):

1. `07_curry_howard.py` — the conceptual apex; entire theory arc depends on its quality
2. `06_gentzen_or.py` — seeds the apex; must land cleanly to make B work
3. `17_stage3_sealed_delete.py` — most dramatic practical moment; shortest build time
4. `22_stage6_linearity.py` — closes the arc; QTT callback
5. `09_lambda_cube.py` — sets expectations for Stage 6; serves as prospective/retrospective map
6. `11_session_types.py` (MANIM F) — Danielle's resolution; protocol visualisation
7. `05_historical_timeline.py` — replaces static S7; significant quality improvement
8. `18_stage4_live_uncomment.py` — Charlie's resolution
9. `10_incident_badges.py` — narrative thread; implement early, use everywhere
10. `13_agentic_overlay.py` and `14_close_echo.py` — low build cost, high emotional payoff
11. `15_stage0_terminal.py` — sets the baseline tone
12. Remaining navigation scenes (`19`, `20`, `21`, `23`) — implement last; high effort, moderate impact

---

### 12.12 Summary of Narrative Arc Improvements

| Issue | Original plan | Revised plan |
|-------|--------------|--------------|
| ∨E told 3 times | MANIM A ends with `≡`, MANIM B repeats ∨E, B1 re-shows rule | MANIM A seeds, MANIM B generalises (adds →E), B1 is code-only with footnote |
| Theory section drags (S7, S8 static) | Slide PNG fade-in | Timeline animation + Russell flash overlay |
| Lambda cube is abstract | 4 axes, no talk connection | Each axis labelled with stage range; path traces the whole talk |
| No narrative thread through stage arc | Incident slides standalone | Badge tracking thread: open at S2–S5, close progressively through S21/S24/S29 |
| S35 (Agentic) is flat | Fade-in | Code generation + scan animation (8s overlay) |
| S38 (Close) loses the arc | Fade-in static | Ghost code echoes as names are spoken |
| MANIM E redundant | "Bob's bug" reimplemented conceptually | Removed; Stage 3 demo is the single animated payoff |
| MANIM B pulls out ∨E fragments | Only ∨E node extracted | Entire proof tree and program lifted — the WHOLE proof = WHOLE program |
