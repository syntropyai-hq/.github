# Contributing

These are the rules every repository in [syntropyai-hq](https://github.com/syntropyai-hq) shares. A repository with its own `CONTRIBUTING.md` adds to them, and where the two differ, the repository's file wins.

## Before you start

1. Search the repository's open and closed issues and pull requests. If one covers your point, add your evidence there.
2. For anything larger than a focused fix, open an issue first that says what problem it solves, what it changes and what it costs.

Don't report a security problem in a public issue. Use [SECURITY.md](SECURITY.md).

## Pull requests

- **One change per pull request.** Keep unrelated formatting, refactors and dependency changes out.
- **Title.** A conventional commit, `type(scope): subject`, where `type` is one of `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, `build`, `ci`, `chore` or `revert`. The scope may be left out. Pull requests are squash-merged, so the title becomes the commit message.
- **Sign off every commit.** Each commit carries a Developer Certificate of Origin line, `Signed-off-by: Your Name <you@example.com>`, matching the commit's author. `git commit -s` adds it. By signing off you certify the [DCO](https://developercertificate.org/) for that commit. There is no CLA.
- **Pass the checks.** Run the repository's lint, format and test commands before you push. Its README or `CONTRIBUTING.md` lists them.
- **Update the docs in the same pull request** where the change alters what a user needs to know.

## Evidence

Every claim in an issue or a pull request has to be checkable.

- **Never submit a measurement, log, test result or reproduction you did not produce.**
- **Label what you haven't run.** A finding from reading code or from a scanner is unconfirmed until it runs. Explain the path you suspect and what would confirm it.
- **Report validation as it happened.** List the exact commands, the commit and the environment, and keep passed, failed and not run apart.
- **Say what a number is.** A target says it is one, an estimate shows its derivation, and a measurement names the commit, the hardware and how it was taken.

## Licence

Projects here are licensed under MIT OR Apache-2.0 unless a repository says otherwise. Contributions are accepted under the same terms, inbound equals outbound, certified by the DCO sign-off.
