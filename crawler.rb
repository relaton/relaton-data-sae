# frozen_string_literal: true

# Crawler entry point. relaton/support's shared crawler.yml runs
# `bundle exec ruby crawler.rb`, then zips every changed index*.yaml and
# commits data/ with the yaml and zip. Nothing is zipped here.
#
# Walks SAE's Crossref deposits (prefix 10.4271, type standard; ~48 requests
# at one a second, no credentials) and writes data/*.yaml and index-v2.yaml.
# Ids that Pubid::Sae cannot parse are written to data/ but not indexed, and
# are logged (~966 expected: 791 CP* collected papers, the rest one-off
# codes). That is not a failure.

require "fileutils"
require "relaton/sae/data_fetcher"

# Narrower than `index*`, which would also match a Ruby source named index*.rb
# next to this file -- relaton-data-bipm hit that bug. spec/crawler_spec.rb
# guards it.
FileUtils.rm Dir.glob("index-v*.{yaml,zip}")

# data/ is kept, not removed: `prune: true` deletes the files this run did not
# write (withdrawn editions), but only when the run wrote at least 90% of the
# existing corpus. A crawl that stops early therefore leaves data/ as it was,
# where an `rm -rf data` would commit and publish a mass deletion.
Relaton::Sae::DataFetcher.fetch "sae-crossref", prune: true
