# Global Preferences

## Writing

- Never write an em-dash (U+2014) or en-dash (U+2013) in prose you author. Use a comma, a colon, or a rewritten sentence instead, and a plain hyphen for ranges (3-5). Reproduce code, file contents, quotes, and command output exactly as they are. A line you rewrite is prose you author, even when the old line had a dash.

## Spiral

- Prose in my voice (posts, threads, emails, newsletters, blog posts, essays, or "rewrite this in my voice", "remove the AI tells") goes through the Spiral MCP tools, not through you or a prose skill.
- Show Spiral's result verbatim. My chat tone rules and the dash rule apply to your replies, not to Spiral's drafts.
- Put "no em dashes or en dashes" in every Spiral brief.

## Documentation

- For a known site's docs, try `llms.txt` or `llms-full.txt` at the root first (e.g. `https://example.com/llms.txt`); fall back to the HTML docs if it 404s or lacks what you need.

## Code

- Write the minimum code that does the job, and bias toward deletion: dead code, unused imports, unnecessary abstractions.
- Prefer TDD.
- Prefer bun over node.

## Scripts

- If it needs a pipe, a loop, a conditional, or more than one line, it is a script. Single self-contained commands (`grep`, `git status`) are fine as-is.
- A script that stays in the repository is written in that repository's own language, following its conventions. If the repo has no code, only documents and config, use Ruby.
- A throwaway script (data munging, one-off migration, file renames, glue code) is written in Ruby, whatever the repo's language. Edits to source files go through the Edit tool, not a script.
- In Ruby, use only the standard library. If a gem would clearly save significant effort, stop and ask before using it.
- Put temporary scripts in a fresh `mktemp -d` directory, and delete it when done unless asked to keep it.

## Dependencies

- Do not install, add, or recommend a package until you have opened the upstream project's own repo or docs and used the install command published there. Never work backwards from a search result or a registry page to a project. If anything about the package looks off, stop and ask me: do not work around it, do not pin around it, do not quietly substitute an alternative. Load the `dependency-vetting` skill for the full checks.

## Shell

- My zsh sets `noclobber`, so a plain `>` fails when the file exists. Use `>|` to overwrite, and `>>` only when you actually intend to append.
- zsh expands a word that starts with `=` to a command path, so quote it: `echo '====='`.
- zsh stops on a glob with no match, flags included, so quote it: `--include='*.go'`.
- macOS grep has no `-P`. Use `rg` for Unicode or Perl-style patterns.

## Git

Use conventions below unless the project's standards demand otherwise. In that case use project's conventions.

- Squash merge is the default strategy for pull requests.
- Close an issue only once its code is merged into the default branch. Until then, leave it open and say the close waits on the merge.
- Commits use Conventional Commits: `type(scope): description`.
- Branches use the same types: `type/kebab-description`, as in `feat/forge-detection-controls` or `fix/site-omit-unreleased`.
- A release branch is `chore/release-X.Y.Z`.
- No `Generated with`, `Co-Authored-By: Claude`, or tool attribution footers.
- Never hard-wrap commit messages or pull request descriptions. One paragraph is one line; let the renderer wrap it.

@RTK.md

<!-- CODEGRAPH_START -->

## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
