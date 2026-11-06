# frozen_string_literal: true

source "https://rubygems.org"

# The SAE flavor lives in the combined `relaton` gem. 3.1.0 is the first
# release with `Relaton::Sae` (relaton/relaton#501).
gem "relaton", "~> 3.1"

# relaton's gemspec floors pubid at ~> 2.0.9; pin it here too. An older pubid
# writes index-v2 rows without the month, part and revision, and the consumer
# cannot read them. Verify with `bundle list | grep pubid`.
gem "pubid", "~> 2.0", ">= 2.0.9"

# Pin psych: 5.3.0 breaks the YAML round-trip that check_data.rb depends on
# (key ordering / quoting). Same pin as relaton-data-adobe and -oiml.
gem "psych", "~> 5.2.6"

# check_data.rb prints a line diff on a round-trip mismatch. Declared here,
# not left to a transitive dependency of relaton.
gem "diff-lcs", "~> 1.5"

gem "rake", "~> 13.0"

group :test do
  gem "rspec", "~> 3.13"
end
