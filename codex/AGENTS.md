# Global preferences

## Communication

- Use ASD-STE100 Simplified Technical English.
- Lead with the outcome.
- Keep replies brief and focused.
- Give a high-level explanation unless I ask for detail.
- Match written deliverables to the task.
- Omit filler sections, repeated summaries, and boilerplate.
- Add short codes to lists with three or more related items.
- Use category prefixes such as `F1`, `O1`, `D1`, `R1`, `Q1`, or `A1`.
- Keep each item's code stable during the conversation.
- Before long work, state the next action in one sentence.
- Send an update only for a finding or a change of direction.
- State uncertainty plainly.
- Run cheap checks before you report uncertainty.
- Never invent a contrast to add emphasis.
- Avoid these phrases: "load-bearing", "worth stating plainly", "here's the
  honest truth", "the real tension", and "carry the argument".
- Describe the actual subject directly.
- Use an analogy only when I ask for one.

## Delegation

- Dispatch subagents for parallel searches across unknown scope.
- Dispatch independent code and documentation review passes.
- Follow skills and planning flows that require subagents.
- Treat this section as my standing request for those cases.
- Independent corroboration requires separately dispatched contexts.
- Describe harness constraints as harness constraints.
- Never describe a harness constraint as my preference.

## Writing

- Never write an em dash or en dash in authored prose.
- Use commas, colons, rewritten sentences, or plain hyphens.
- Reproduce code, file contents, quotations, and command output exactly.

## Documentation

- For known documentation sites, try `llms.txt` or `llms-full.txt` at the site
  root first.
- Use the HTML documentation when those files fail or lack the required facts.

## Code

- Write the minimum code that completes the task.
- Delete dead code, unused imports, and unnecessary abstractions.
- Prefer test-driven development.
- Prefer Bun over Node.js.

## Scripts

- Treat a pipe, loop, conditional, or multi-line command as a script.
- Keep single commands such as `grep` or `git status` as shell commands.
- Write committed scripts in the repository's language and conventions.
- Use Ruby when a repository contains only documentation and configuration.
- Write throwaway scripts in Ruby.
- Use only the Ruby standard library.
- Ask before using a gem that saves significant effort.
- Put temporary scripts in a scratch or temporary directory.
- Delete temporary scripts when the task ends, unless I ask to keep them.

## Dependencies

- Before adding, upgrading, or recommending a dependency, open its upstream
  repository or documentation.
- Use the installation command published by the upstream project.
- Treat search results and registry pages as discovery sources only.
- Stop and ask when the package or installation details do not match.
- Load the `dependency-vetting` skill for the full checks.

## Shell

- My Z shell uses `noclobber`.
- Use `>|` to overwrite a file.
- Use `>>` only to append.
- Prefix supported development commands with `rtk`.

## Git

- Use repository standards when they differ from these defaults.
- Use squash merge for pull requests.
- Use Conventional Commits: `type(scope): description`.
- Use `type/kebab-description` for branches.
- Use `chore/release-X.Y.Z` for release branches.
- Omit generated, co-author, and tool-attribution footers.
- Use `gh` for all GitHub operations.
- Never hard-wrap commit messages or pull request descriptions.
- Write each paragraph as one line and let the renderer wrap it.
