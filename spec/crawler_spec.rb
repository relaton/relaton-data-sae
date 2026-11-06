# frozen_string_literal: true

require "relaton/sae/data_fetcher"

RSpec.describe "crawler.rb" do
  around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) { example.run }
    end
  end

  before do
    FileUtils.mkdir_p "data"
    File.write "data/sae-stale.yaml", "stale"
    %w[index-v2.yaml index-v2.zip index-v1.yaml].each { |f| File.write f, "old" }
    # A source file next to the indexes: a bare `index*` glob deletes it
    # (the relaton-data-bipm bug).
    File.write "index_builder.rb", "# source"
    allow(Relaton::Sae::DataFetcher).to receive(:fetch)
  end

  def run_crawler
    load File.join(ROOT, "crawler.rb")
  end

  it "fetches the sae-crossref dataset in prune mode" do
    run_crawler
    expect(Relaton::Sae::DataFetcher).to have_received(:fetch)
      .with("sae-crossref", prune: true)
  end

  # prune mode deletes stale files only after a near-complete crawl (core's
  # 90% guard). An `rm -rf data` first would publish a truncated crawl as a
  # mass deletion.
  it "keeps data/ and removes only the indexes before the fetch" do
    expect(Relaton::Sae::DataFetcher).to receive(:fetch) do
      expect(File).to exist("data/sae-stale.yaml")
      expect(Dir.glob("index-v*")).to be_empty
    end
    run_crawler
  end

  it "keeps non-index files that start with 'index'" do
    run_crawler
    expect(File).to exist("index_builder.rb")
  end
end
