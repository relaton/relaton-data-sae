# frozen_string_literal: true

RSpec.describe "check_data.rb" do
  let(:fixture) { File.join(ROOT, "spec/fixtures/data/sae-j3016_201609.yaml") }

  around do |example|
    Dir.mktmpdir do |dir|
      @dir = dir
      example.run
    end
  end

  def check(glob = File.join(@dir, "*.yaml"))
    Open3.capture2e("bundle", "exec", "ruby", File.join(ROOT, "check_data.rb"),
                    glob, chdir: ROOT)
  end

  it "passes a document that round-trips" do
    FileUtils.cp fixture, @dir
    out, status = check
    expect(status).to be_success, out
    expect(out).to include "OK"
  end

  it "passes an empty data directory" do
    out, status = check
    expect(status).to be_success, out
  end

  it "fails a document without a primary docidentifier" do
    yaml = File.read(fixture, encoding: "UTF-8").sub("  primary: true\n", "")
    File.write File.join(@dir, "sae-noprimary.yaml"), yaml
    out, status = check
    expect(status).not_to be_success
    expect(out).to include "No primary docidentifier"
  end

  it "fails a document that does not round-trip" do
    yaml = File.read(fixture, encoding: "UTF-8").sub("type: standard\n", "type: standard\nunknown_key: x\n")
    File.write File.join(@dir, "sae-mangled.yaml"), yaml
    out, status = check
    expect(status).not_to be_success
    expect(out).to include "Round-trip mismatch in #{File.join(@dir, 'sae-mangled.yaml')}"
  end
end
