# syntropyai-hq/.github

The organisation's shared files. GitHub reads them from this repository by name.

| Path | What it holds |
|---|---|
| [`profile/README.md`](profile/README.md) | The public organisation page at [github.com/syntropyai-hq](https://github.com/syntropyai-hq) |
| [`profile/media/`](profile/media/) | The logo in light and dark versions, the organisation avatar, and the social preview cards for the organisation's repositories and for syntropy. Each `.svg` is the source of the `.png` uploaded to GitHub |
| [`CONTRIBUTING.md`](CONTRIBUTING.md), [`SECURITY.md`](SECURITY.md) | The defaults for every repository that has no file of its own |
| [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/), [`.github/pull_request_template.md`](.github/pull_request_template.md) | The default issue forms and pull request template, on the same terms |
| [`settings/`](settings/) | The organisation's settings as code. `settings/apply.sh` prints what it would change, and `--apply` changes it and reads every setting back |

Repository settings live with each repository, in its `ci/repo-settings/`.

Licensed under either of [MIT](LICENSE-MIT) or [Apache-2.0](LICENSE-APACHE), at your option.
