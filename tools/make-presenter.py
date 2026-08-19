#!/usr/bin/env python3
"""Build a self-contained two-screen presenter for the deck.

Why this exists
---------------
touying's html export is impress.js: one 10.3 MB document with 49 inline SVGs,
and its presenter console keeps THREE live copies of it (main + two iframes) on
3D-transformed containers. Past about a dozen steps the compositor drops the
layers and the frames paint grey while the DOM underneath is still correct.
Reproduced over http in headless Chromium, so it is neither a browser bug nor a
file:// problem, and it is not fixable from outside touying.

This sidesteps the whole class:

  * one flat PNG per slide, loaded lazily as <img> — never 49 at once
  * no impress.js, no 3D transforms, no iframes
  * audience window and presenter window are two REAL windows, so you drag the
    presenter to your laptop screen and fullscreen the other on the projector
  * they sync over postMessage, which is cross-origin-safe by design and so
    works from file:// as well as http:// — this is precisely the mechanism
    touying's console does not use

Output is a folder that can be copied or zipped anywhere:

    presenter/
      index.html      notes inlined (file:// forbids fetching a sibling .json)
      slides/001.png …

    python3 tools/make-presenter.py [--ppi 144] [--full-notes]

Then open presenter/index.html and press P.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
DECK = os.path.join("touying", "deck.typ")
# Vendored fonts — see the note in touying/theme.typ. Keep in step with the
# TYPST_FONTS variable in the Makefile.
FONT_ARGS = ["--font-path", os.path.join("touying", "fonts"), "--ignore-system-fonts"]
PDFPC = os.path.join(ROOT, "talk.pdfpc")
OUT = os.path.join(ROOT, "presenter")

PREP_RULE = re.compile(r"^={20,}\s*$", re.M)

TEMPLATE = r"""<!doctype html>
<meta charset="utf-8">
<title>__TITLE__</title>
<style>
  :root { color-scheme: dark; }
  * { box-sizing: border-box; }
  html, body { margin:0; height:100%; background:#0d1016; color:#e8e4dc;
               font-family: "IBM Plex Sans", system-ui, sans-serif; overflow:hidden; }
  img { display:block; }

  /* ---- audience view ---- */
  #stage { height:100%; display:grid; place-items:center; background:#0d1016; }
  #stage img { max-width:100%; max-height:100%; object-fit:contain; }
  #hint { position:fixed; left:0; right:0; bottom:0; padding:.5rem .9rem; font-size:.8rem;
          color:#8b8f98; background:rgba(0,0,0,.55); text-align:center;
          transition:opacity .4s; }
  #hint.gone { opacity:0; pointer-events:none; }

  /* ---- presenter view ---- */
  /* The thumbnails are bounded by VIEWPORT HEIGHT, never by their own width.
     Sizing them by width (width:100%) makes a wide window produce a tall image,
     which eats the column and squeezes the notes to a single line — that was
     the first version's bug. The notes are what gets read under pressure, so
     they take everything left over and never less than half the height. */
  #console { display:none; height:100%; grid-template-columns: 2fr 1fr;
             grid-template-rows: minmax(0, 34vh) minmax(0, 1fr) auto;
             gap:.7rem; padding:.7rem; }
  #console.on { display:grid; }
  #cur  { grid-column:1; grid-row:1; min-height:0; min-width:0; display:flex;
          align-items:flex-start; justify-content:flex-start; }
  #cur img { max-width:100%; max-height:100%; width:auto; height:auto;
             object-fit:contain; border:1px solid #262b36; border-radius:6px; }
  #side { grid-column:2; grid-row:1; min-height:0; min-width:0; display:flex;
          flex-direction:column; align-items:flex-start; }
  #nextWrap { border:1px solid #262b36; border-radius:6px; overflow:hidden;
              min-height:0; display:flex; }
  #nextWrap img { max-width:100%; max-height:100%; width:auto; height:auto;
                  object-fit:contain; display:block; }
  #nextLbl { font-size:.72rem; letter-spacing:.08em; text-transform:uppercase;
             color:#8b8f98; margin-bottom:.25rem; flex:0 0 auto; }
  #notes { grid-column:1 / span 2; grid-row:2; min-height:0; overflow-y:auto;
           padding:.8rem 1.1rem; background:#12161f; border:1px solid #262b36;
           border-radius:6px; white-space:pre-wrap;
           font-size:clamp(1rem, 1.35vh + .55rem, 1.5rem); line-height:1.5; }
  #bar { grid-column:1 / span 2; grid-row:3; display:flex; align-items:center;
         flex:0 0 auto; gap:1.2rem; font-variant-numeric:tabular-nums;
         color:#b9bcc4; font-size:.95rem; }
  #bar b { color:#e8e4dc; font-weight:600; }
  #bar .grow { margin-left:auto; }
  button { background:#1b2030; color:#e8e4dc; border:1px solid #2e3547;
           border-radius:5px; padding:.3rem .7rem; font:inherit; font-size:.95rem;
           line-height:1.2; cursor:pointer; flex:0 0 auto; }
  button:hover { background:#232a3d; }
  #elapsed.over { color:#e08a4a; }
  #elapsed.paused { color:#8b8f98; }
  button.off { color:#8b8f98; border-color:#242a38; }
  kbd { background:#1b2030; border:1px solid #2e3547; border-radius:3px;
        padding:0 .3rem; font-size:.85em; }
  #fallback { position:fixed; left:1rem; bottom:1rem; max-width:52rem;
              padding:1rem 1.2rem; background:#2a1d16; border:1px solid #7a4a24;
              border-radius:8px; color:#f0e6dc; font-size:1rem; z-index:9; }
  #fallback.quiet { background:rgba(0,0,0,.5); border-color:#2e3547; color:#8b8f98;
                    padding:.35rem .7rem; font-size:.8rem; }
  #fallback p { margin:0 0 .5rem; }
  #fallback a { color:#e08a4a; word-break:break-all; }
  #fallback button { margin-top:.6rem; }
</style>

<div id="stage"><img id="slide" alt=""></div>
<div id="hint">
  <kbd>→</kbd> next · <kbd>←</kbd> back · <kbd>F</kbd> fullscreen ·
  <kbd>P</kbd> presenter window · <kbd>B</kbd> black
</div>

<div id="console">
  <div id="cur"><img id="cImg" alt=""></div>
  <div id="side">
    <div>
      <div id="nextLbl">next</div>
      <div id="nextWrap"><img id="nImg" alt=""></div>
    </div>
  </div>
  <div id="notes"></div>
  <div id="bar">
    <button onclick="go(idx-1)">◀ prev</button>
    <button onclick="go(idx+1)">next ▶</button>
    <span><b id="pos"></b> / __N__</span>
    <span class="grow">elapsed <b id="elapsed">00:00</b></span>
    <span>clock <b id="clock"></b></span>
    <button id="pauseBtn" onclick="togglePause()">&#9208; pause</button>
    <button onclick="resetTimer()">reset</button>
    <button id="clickBtn" onclick="toggleClickAdvance()">top-click: on</button>
  </div>
</div>

<script>
const SLIDES = __SLIDES__;      // ["slides/001.png", ...]
const NOTES  = __NOTES__;       // ["...", ...]
const N      = SLIDES.length;
const TARGET_MIN = __TARGET__;  // planned run time, for the elapsed colour

const qs = new URLSearchParams(location.search);
const isConsole = qs.get('view') === 'console';
let idx = 0, peer = null, started = null, blacked = false;
/* Timer: `started` is the epoch it began. `pausedAt` is set while paused, and
   `pausedTotal` accumulates the time spent paused, so elapsed stays honest
   across any number of pauses. All three travel in the sync message. */
let pausedAt = null, pausedTotal = 0;
let clickAdvance = true;

/* ---------- sync ----------
   postMessage is cross-origin-safe by design, so this works from file:// where
   BroadcastChannel and localStorage do not. Both directions, so either window
   can drive. */
function send(msg) {
  try { if (peer && !peer.closed) peer.postMessage(msg, '*'); } catch (e) {}
  try { if (window.opener && !window.opener.closed) window.opener.postMessage(msg, '*'); } catch (e) {}
}
addEventListener('message', e => {
  const m = e.data;
  if (!m || typeof m !== 'object') return;
  if (m.type === 'goto')  render(m.i);
  if (m.type === 'hello') { if (!isConsole) { helloSeen = helloEver = true;
        peer = e.source; clearTimeout(waitTimer); clearNotice();
        send({type:'goto', i: idx}); } }
  if (m.type === 'timer') { started = m.started; pausedAt = m.pausedAt || null;
        pausedTotal = m.pausedTotal || 0; paintTimerButton(); }
});

function preload(i) {
  for (const j of [i+1, i+2, i-1]) if (j >= 0 && j < N) { const im = new Image(); im.src = SLIDES[j]; }
}

function render(i) {
  idx = Math.max(0, Math.min(N - 1, i));
  const src = SLIDES[idx];
  if (isConsole) {
    document.getElementById('cImg').src = src;
    document.getElementById('nImg').src = idx + 1 < N ? SLIDES[idx+1] : '';
    document.getElementById('notes').textContent = NOTES[idx] || '(no notes)';
    document.getElementById('notes').scrollTop = 0;
    document.getElementById('pos').textContent = idx + 1;
  } else {
    document.getElementById('slide').src = blacked ? '' : src;
  }
  preload(idx);
}

function go(i) {
  if (i < 0 || i >= N) return;
  render(i);
  send({type:'goto', i: idx});
  if (!started) { started = Date.now(); syncTimer(); paintTimerButton(); }
}

/* Build the console URL from location.href, never from location.pathname.
   pathname drops the host and mangles drive letters, so on Windows — and
   especially when the folder is opened across \\wsl.localhost\... — the popup
   loaded nothing and painted an empty window. href is always absolute. */
function consoleURL() {
  const u = new URL(location.href);
  u.search = '?view=console';
  u.hash = '';
  return u.href;
}

/* The notice lives on the AUDIENCE window, which is the projector, so it must
   never cry wolf in front of the room:
     - once a console has connected even once, it is never shown again;
     - a cold load from a slow path can take a while, so the wait is 12s, and
       until then it is only a small "opening…" chip, not a warning. */
let helloSeen = false, helloEver = false, waitTimer = null;
function openConsole() {
  // Must be called from a key/click handler or popup blockers eat it.
  peer = window.open(consoleURL(), 'presenter', 'width=1200,height=800');
  if (!peer) { showNotice('blocked'); return; }
  helloSeen = false;
  showNotice('waiting');
  clearTimeout(waitTimer);
  waitTimer = setTimeout(() => { if (!helloSeen) showNotice('failed'); }, 12000);
}

function clearNotice() { const el = document.getElementById('fallback'); if (el) el.remove(); }

function showNotice(kind) {
  if (helloEver) return;               // it has worked once; never alarm the room
  clearNotice();
  const el = document.createElement('div');
  el.id = 'fallback';
  el.className = kind === 'waiting' ? 'quiet' : '';
  if (kind === 'waiting') {
    el.textContent = 'opening presenter window…';
  } else {
    const p = document.createElement('p');
    p.textContent = kind === 'blocked'
      ? 'The presenter window was blocked. Allow pop-ups for this page, then press P again — or open this address in a second window:'
      : 'The presenter window has not reported in. Open this address in a second window:';
    const a = document.createElement('a');
    a.href = consoleURL(); a.target = '_blank'; a.rel = 'noopener';
    a.textContent = consoleURL();
    const b = document.createElement('button');
    b.textContent = 'dismiss';
    b.onclick = clearNotice;
    el.append(p, a, document.createElement('br'), b);
  }
  document.body.appendChild(el);
}

function toggleFullscreen() {
  const el = document.documentElement;
  if (!document.fullscreenElement) (el.requestFullscreen || el.webkitRequestFullscreen).call(el);
  else (document.exitFullscreen || document.webkitExitFullscreen).call(document);
}

addEventListener('keydown', e => {
  const k = e.key;
  if (k === 'ArrowRight' || k === 'PageDown' || k === ' ' || k === 'Enter') { e.preventDefault(); go(idx+1); }
  else if (k === 'ArrowLeft' || k === 'PageUp' || k === 'Backspace')       { e.preventDefault(); go(idx-1); }
  else if (k === 'Home') go(0);
  else if (k === 'End')  go(N-1);
  else if (k === 'f' || k === 'F') toggleFullscreen();
  else if (k === 'p' || k === 'P') { if (!isConsole) openConsole(); }
  else if (k === 'b' || k === 'B') { if (!isConsole) { blacked = !blacked; render(idx); } }
  else if (k === 'r' || k === 'R') resetTimer();
});
addEventListener('click', e => { if (!isConsole && e.target.tagName !== 'BUTTON') go(idx+1); });
/* In the console, a click anywhere ABOVE THE NOTES advances — the thumbnails,
   the space between them, the space around them.
   Do NOT test for `e.target.id === 'console'`: that is only ever true for the
   0.7rem grid gap itself. #cur and #side fill their grid cells, so a real click
   in what LOOKS like empty space lands on one of them, and the first version of
   this did nothing anywhere a person would actually click.
   The notes pane and the button bar are excluded so scrolling, selecting and
   pressing a button stay themselves. Toggleable, because an accidental advance
   mid-talk is worse than the convenience is good. */
addEventListener('click', e => {
  if (!isConsole || !clickAdvance) return;
  if (e.target.closest('#notes') || e.target.closest('#bar')) return;
  go(idx + 1);
});

function syncTimer() { send({type:'timer', started, pausedAt, pausedTotal}); }

function resetTimer() {
  started = Date.now(); pausedAt = null; pausedTotal = 0;
  syncTimer(); paintTimerButton();
}

function togglePause() {
  if (!started)        started = Date.now();               // first press starts it
  else if (pausedAt) { pausedTotal += Date.now() - pausedAt; pausedAt = null; }
  else                 pausedAt = Date.now();
  syncTimer(); paintTimerButton();
}

function elapsedSec() {
  if (!started) return 0;
  const now = pausedAt || Date.now();
  return Math.max(0, Math.floor((now - started - pausedTotal) / 1000));
}

function paintTimerButton() {
  const b = document.getElementById('pauseBtn');
  if (b) b.innerHTML = pausedAt ? '&#9654; resume' : '&#9208; pause';
  const el = document.getElementById('elapsed');
  if (el) el.classList.toggle('paused', !!pausedAt);
}

function toggleClickAdvance() {
  clickAdvance = !clickAdvance;
  const b = document.getElementById('clickBtn');
  if (b) { b.textContent = 'top-click: ' + (clickAdvance ? 'on' : 'off');
           b.classList.toggle('off', !clickAdvance); }
}
function two(n) { return String(n).padStart(2, '0'); }
setInterval(() => {
  if (!isConsole) return;
  const c = document.getElementById('clock');
  if (c) { const d = new Date(); c.textContent = two(d.getHours()) + ':' + two(d.getMinutes()); }
  const el = document.getElementById('elapsed');
  if (el) {
    const s = elapsedSec();
    el.textContent = two(Math.floor(s/60)) + ':' + two(s % 60);
    el.classList.toggle('over', s > TARGET_MIN * 60);
  }
}, 1000);

if (isConsole) {
  document.getElementById('console').classList.add('on');
  document.getElementById('stage').style.display = 'none';
  document.getElementById('hint').style.display = 'none';
  send({type:'hello'});
} else {
  setTimeout(() => document.getElementById('hint').classList.add('gone'), 6000);
}
render(0);
</script>
"""


def notes_from_pdfpc(keep_prep):
    if not os.path.exists(PDFPC):
        sys.exit("talk.pdfpc not found — run `make all` first.")
    with open(PDFPC, encoding="utf-8") as fh:
        pages = json.load(fh)["pages"]
    out = []
    for p in pages:
        n = p.get("note") or ""
        out.append(n.strip() if keep_prep else PREP_RULE.split(n, maxsplit=1)[0].strip())
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ppi", type=int, default=144)          # 144 -> 1920x1080
    ap.add_argument("--full-notes", action="store_true")
    ap.add_argument("--target-minutes", type=int, default=45)
    args = ap.parse_args()

    notes = notes_from_pdfpc(args.full_notes)

    slides_dir = os.path.join(OUT, "slides")
    shutil.rmtree(slides_dir, ignore_errors=True)
    os.makedirs(slides_dir, exist_ok=True)
    subprocess.run(
        ["typst", "compile", "--root", ".", *FONT_ARGS, DECK,
         os.path.join(slides_dir, "{0p}.png"), "--format", "png", "--ppi", str(args.ppi)],
        cwd=ROOT, check=True,
    )
    files = sorted(f for f in os.listdir(slides_dir) if f.endswith(".png"))
    if len(files) != len(notes):
        print(f"warning: {len(files)} slides rendered, {len(notes)} notes", file=sys.stderr)

    html = (TEMPLATE
            .replace("__TITLE__", "Type-Driven Programming — presenter")
            .replace("__SLIDES__", json.dumps([f"slides/{f}" for f in files]))
            .replace("__NOTES__", json.dumps(notes[:len(files)]))
            .replace("__N__", str(len(files)))
            .replace("__TARGET__", str(args.target_minutes)))
    with open(os.path.join(OUT, "index.html"), "w", encoding="utf-8") as fh:
        fh.write(html)

    total = sum(os.path.getsize(os.path.join(slides_dir, f)) for f in files)
    print(f"{OUT}/index.html — {len(files)} slides, {sum(1 for n in notes if n)} with notes, "
          f"{total/1e6:.0f} MB of images, {args.ppi} ppi")
    print("open presenter/index.html and press P")


if __name__ == "__main__":
    main()
