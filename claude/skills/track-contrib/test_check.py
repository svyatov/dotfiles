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


def run(store):
    r = subprocess.run([sys.executable, str(SCRIPT), "check"], capture_output=True,
                       text=True, env=dict(ENV, CONTRIB_DIR=str(store)))
    assert r.returncode == 0, r.stderr
    return r.stdout


def records(store):
    return {json.loads(l)["item"]: json.loads(l)
            for l in (store / "items.jsonl").read_text().splitlines()}


with tempfile.TemporaryDirectory() as tmp:
    store = pathlib.Path(tmp)
    shutil.copy(T / "items.jsonl", store)
    first = run(store)

    if "--bless" in sys.argv:
        (T / "golden.txt").write_text(first)
        sys.exit("blessed t/golden.txt")

    assert first == (T / "golden.txt").read_text(), (
        "output changed. diff it:\n"
        f"  python3 {pathlib.Path(__file__).name} --bless  # once the change is wanted")

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
