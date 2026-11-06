#!/usr/bin/env ruby
# frozen_string_literal: true

# Round-trip validator, run by relaton/support's shared check-data.yml: load
# each data/*.yaml through Relaton::Sae::Item, re-serialize it, and diff
# against the source. Exit 1 on a mismatch or a missing primary docidentifier.
#
#   bundle exec ruby check_data.rb [GLOB]   # default: data/*.{yaml,yml}

require "relaton/sae"

path = ARGV.first || "data/*.{yaml,yml}"

def report_mismatch(file, src, out)
  require "diff/lcs"
  puts "Round-trip mismatch in #{file}:"
  Diff::LCS.sdiff(src.split("\n"), out.split("\n")).each do |change|
    case change.action
    when "-" then puts "  - #{change.old_element}"
    when "+" then puts "  + #{change.new_element}"
    when "!" then puts "  - #{change.old_element}\n  + #{change.new_element}"
    end
  end
  puts
end

errors = false
Dir[path].sort.each do |file|
  # UTF-8 explicitly: a binary-encoded string with non-ASCII content never
  # compares equal to the UTF-8 serialization, even when the bytes match.
  yaml = File.read(file, encoding: "UTF-8")
  item = Relaton::Sae::Item.from_yaml(yaml)

  unless item.docidentifier.find(&:primary)
    errors = true
    puts "Parsing #{file} failed. No primary docidentifier."
    next
  end

  reserialized = item.to_yaml
  next if reserialized == yaml

  errors = true
  report_mismatch file, yaml, reserialized
rescue StandardError => e
  errors = true
  puts "Parsing #{file} failed: #{e.message}"
  puts e.backtrace.first(5)
  puts
end

exit(1) if errors
puts "OK: all data files round-trip cleanly."
