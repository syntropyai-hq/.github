# Security

This is the default policy for every repository in [syntropyai-hq](https://github.com/syntropyai-hq). A repository with its own `SECURITY.md` replaces it, and that file also describes what the project exposes.

## Reporting a vulnerability

Report anything that shouldn't be public until it is fixed **privately**, through GitHub's private vulnerability reporting: the affected repository's **Security** tab, then **Report a vulnerability**. Don't open a public issue.

Include what you found, how to reproduce it (the commit or version and the configuration involved), and what an attacker gains. Reports are triaged by the maintainers.

### What happens next

| Step | Target |
|---|---|
| Acknowledge the report | within 3 business days |
| Assess it and agree a severity | within 10 business days |
| Fix or mitigate a critical issue | within 30 days |
| Disclose, in coordination with you | within 90 days |

Fixes are announced through the repository's GitHub security advisories, which can assign CVE IDs. You are credited in the advisory unless you ask not to be. Every security fix gets a regression test.

There is no bug bounty.
