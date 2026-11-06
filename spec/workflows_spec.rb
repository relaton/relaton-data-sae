# frozen_string_literal: true

# The workflows are Cimas-managed: relaton/support copies its templates over
# them on every `cimas sync`. A copy that differs here is reverted silently, so
# keep them byte-identical. Skipped when relaton/support is not checked out next
# to this repo.
RSpec.describe "Cimas-managed workflows" do
  templates = File.expand_path("../support/cimas-config/gh-actions", ROOT)
  map = {
    "check-index.yml" => "data/check-index.yml",
    "check_data.yml" => "data/check_data.yml",
    "crawler.yml" => "data/crawler.yml",
    "deploy.yml" => "data/deploy.yml",
    "keep-alive.yml" => "master/keep-alive.yml",
  }

  map.each do |name, template|
    it "#{name} matches the Cimas template #{template}" do
      src = File.join(templates, template)
      skip "relaton/support not checked out at #{templates}" unless File.exist?(src)

      expect(File.read(File.join(ROOT, ".github/workflows", name))).to eq File.read(src)
    end
  end
end
