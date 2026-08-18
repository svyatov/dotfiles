#!/usr/bin/env python3
"""One seam: the whole script with the fetch stubbed. Ticket 08.

    python3 test_check.py            assert against t/golden.txt
    python3 test_check.py --bless    rewrite t/golden.txt from the current output
"""
import json, os, pathlib, shutil, subprocess, sys, tempfile

HERE = pathlib.Path(__file__).parent
SCRIPT, T = HERE / "track-contrib", HERE / "t"
ENV = dict(os.environ, NO_COLOR="1", CONTRIB_NOW="2026-08-06T12:00:00Z",
           CONTRIB_FIXTURE=str(T / "out.json"))


def run(store, *flags, env=None):
    e = dict(ENV, CONTRIB_DIR=str(store), **(env or {}))
    e = {k: v for k, v in e.items() if v is not None}  # None unsets, for NO_COLOR
    r = subprocess.run([sys.executable, str(SCRIPT), "check", *flags], capture_output=True,
                       text=True, env=e)
    assert r.returncode == 0, r.stderr
    return r.stdout


def fresh(tmp, name):
    """Each rendering needs an untouched store: the first run drops the terminal
    rows and advances seen, so a later run has no NEW and no LEAVING section."""
    store = pathlib.Path(tmp) / name
    store.mkdir()
    shutil.copy(T / "items.jsonl", store)
    return store


def records(store):
    return {json.loads(l)["item"]: json.loads(l)
            for l in (store / "items.jsonl").read_text().splitlines()}


with tempfile.TemporaryDirectory() as tmp:
    store = fresh(tmp, "ansi")
    first = run(store)
    md = run(fresh(tmp, "md"), "--md")
    # ticket 13: the rendering you actually look at. Without FORCE_COLOR the
    # escapes never appear here, because a subprocess pipe is not a tty.
    colour = run(fresh(tmp, "colour"), env={"NO_COLOR": None, "FORCE_COLOR": "1"})

    if "--bless" in sys.argv:
        (T / "golden.txt").write_text(first)
        (T / "golden_md.txt").write_text(md)
        (T / "golden_colour.txt").write_text(colour)
        sys.exit("blessed t/golden.txt, t/golden_md.txt and t/golden_colour.txt")

    assert first == (T / "golden.txt").read_text(), (
        "output changed. diff it:\n"
        f"  python3 {pathlib.Path(__file__).name} --bless  # once the change is wanted")
    assert md == (T / "golden_md.txt").read_text(), "markdown output changed"
    assert colour == (T / "golden_colour.txt").read_text(), "colour output changed"
    # ticket 13: the three tiers, and the one state that must escape all of them
    assert "\033[91mreview requested" in colour, "an actionable state must be red"
    assert "\033[32mmerged" in colour, "a resolved state must be green"
    assert "\033[" not in md, "markdown must never carry an escape"
    assert "unreachable" in colour and "\033[91munreachable" not in colour and \
        "\033[32munreachable" not in colour, "unreachable takes no hue"
    # ticket 12: the whole reason this mode exists. Four leading spaces is a
    # markdown code block, which would kill every link inside it.
    assert not any(l.startswith("    ") for l in md.splitlines()), \
        "markdown mode must never indent four spaces"
    assert r"mem\_cache\_store" in md, "a title must not be able to inject markup"

    after = records(store)
    assert "gjtorikian/tailwind_merge#80" not in after, "merged row must leave the store"
    assert "ruby/ruby#9002" not in after, "closed row must leave the store"
    assert after["rails/rails#55000"]["seen"] == "2026-08-06T12:00:00Z", "seen must advance"
    assert after["deadorg/vanished-repo#12"]["seen"] == "2026-08-01T00:00:00Z", \
        "an unreachable row keeps its old seen"
    assert after["ruby/ruby#9001"]["participated"] is False, "watch-only stays watch-only"
    assert after["conventional-commits/parser#55"]["participated"] is True, \
        "participated heals on authorship"

    second = run(store)
    assert "*" not in second.replace("* new since you last looked", ""), \
        "a second run in a row shows no unread markers"
    assert "LEAVING THE TRACKER" not in second, "terminal rows print exactly once"

print("ok")
