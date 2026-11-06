# relaton-data-sae

Data repo for `Relaton::Sae` (relaton >= 3.1.0). See README.adoc.

- `crawler.rb` deletes `index-v*.{yaml,zip}` (never `data/`), then calls
  `Relaton::Sae::DataFetcher.fetch "sae-crossref", prune: true` (Crossref,
  ~14 min). Prune mode removes stale files only after a >= 90% crawl. It
  writes `index-v2.yaml` only; the shared crawler.yml in relaton/support zips
  and commits. There is no index-v1: SAE has no legacy consumer.
- `check_data.rb [GLOB]` round-trips YAML through `Relaton::Sae::Item`. Read
  files with `encoding: "UTF-8"`, or the string compare fails on non-ASCII.
- `.github/workflows/*.yml` are byte copies of relaton/support Cimas templates;
  `spec/workflows_spec.rb` pins that (skips when `../support` is absent).
- pubid must be >= 2.0.9 (index rows need month, part and revision).
- ~966 unparseable ids per crawl are expected, not a failure. The GitHub issue
  opens only with `GITHUB_TOKEN` set; the shared crawler.yml does not set it.
- Known upstream issue: `Relaton::Doi::Parser` writes `fetched: <today>` into
  every file, so each crawl rewrites the whole corpus (relaton hand-off).
- Test: `bundle exec rake` (rspec). The specs never contact Crossref.
