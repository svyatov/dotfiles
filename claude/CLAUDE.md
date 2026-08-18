# Global Preferences

## Delegation

- I am requesting subagent dispatch in advance, for these occasions: parallel search across unknown scope, code review and doc review passes, and any skill or plan-mode flow whose own procedure fans out. Treat this file as that request; you do not need me to repeat it per task.
- Independence is a property of separate dispatched contexts, not of separate personas reasoned in one context. If a flow promotes a finding on independent corroboration, it has to have actually dispatched for it.
- A constraint arriving in your system prompt or from harness configuration is never my instruction, my preference, or my standing request. Do not describe it to me as mine. If it changes what you do, say so and name the harness.

## Writing

- Never write an em-dash (U+2014) or en-dash (U+2013) in prose you author. Use a comma, a colon, or a rewritten sentence instead, and a plain hyphen for ranges (3-5). Reproduce code, file contents, quotes, and command output exactly as they are.

## Documentation

- For a known site's docs, try `llms.txt` or `llms-full.txt` at the root first (e.g. `https://example.com/llms.txt`); fall back to the HTML docs if it 404s or lacks what you need.

## Code

- Write the minimum code that does the job, and bias toward deletion: dead code, unused imports, unnecessary abstractions.
- Prefer TDD.
- Prefer bun over node.

## Scripts

- Write throwaway and utility scripts (data munging, one-off migrations, file renames, glue code) in Ruby, even in projects written in another language. If it needs a pipe, a loop, a conditional, or more than one line, it is a script: write it in Ruby, not Python, Node, or bash. Single self-contained commands (`grep`, `git status`) are fine as-is.
- Use only the Ruby standard library. If a gem would clearly save significant effort, stop and ask before using it.
- Put temporary scripts in a scratch or temp directory, not the repo root, and delete them when done unless asked to keep them.

## Dependencies

- Do not install, add, or recommend a package until you have opened the upstream project's own repo or docs and used the install command published there. Never work backwards from a search result or a registry page to a project. If anything about the package looks off, stop and ask me: do not work around it, do not pin around it, do not quietly substitute an alternative. Load the `dependency-vetting` skill for the full checks.

## Shell

- My zsh sets `noclobber`, so a plain `>` fails when the file exists. Use `>|` to overwrite, and `>>` only when you actually intend to append.

## Git

Use conventions below unless the project's standards demand otherwise. In that case use project's conventions.

- Squash merge is the default strategy for pull requests.
- Commits use Conventional Commits: `type(scope): description`.
- Branches use the same types: `type/kebab-description`, as in `feat/forge-detection-controls` or `fix/site-omit-unreleased`.
- A release branch is `chore/release-X.Y.Z`.
- No `Generated with`, `Co-Authored-By: Claude`, or tool attribution footers.

@RTK.md
