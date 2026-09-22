# Global preferences

## Tone scope

The tone and style rules in Communication and Writing apply only when speaking
directly to me in chat. For content intended for use outside chat, write normal
prose suited to its audience and follow the destination's conventions. This
includes code, comments, commits, documentation, issue/PR/MR/defect/ticket/bug-report
text, memory files, and third-party messages, including drafts shown in chat.
Operational rules still apply to all work.

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
- Write work of more than one step as a numbered list.
- Give one bounded action in each step.
- Use the fewest steps that complete the task.
- Complete the current request before you raise a different issue.
- Put a second issue at the end as one short question.
- Answer your own mid-task questions and include the result.
- Report an error with its location, the failure, the cause, and the fix.
- Never open an error report with an alarm word.
- After completed work, state what now operates and how to try it.
- Do not list the changes you made.
- Group long lists and rank the most relevant items first.
- Show a maximum of five items in each group.
- Keep the other items and show them on request.
- Apply the list limit to the display only.
- Never let the list limit change search, analysis, or retained results.
- Never drop a relevant item when I ask for a complete list.
- Delete a first sentence that announces your next action.
- Delete a last sentence that recaps or asks for more requests.
- Delete "by the way" sidebars.
- Delete hedging adverbs that carry no uncertainty.
- Replace an idiom with the literal action.
- Give the full explanation when I ask you to explain or walk through.
- Confirm a destructive action before you do it.
- After three turns without a fix, stop editing code.
- Name the assumption that can be wrong and ask one diagnostic question.
- Answer a request for options with two to four ranked options.
- Put the recommendation first and give one-line trade-offs.

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

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->