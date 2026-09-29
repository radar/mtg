# frozen_string_literal: true

# Roadmap L1b: how much of the whole Oracle corpus (not one set) the card parser
# recognises, and what blocks "At the beginning of ..." triggers.
#
#   bundle exec ruby script/parser_coverage.rb            # overall numbers + the per-phase table
#   bundle exec ruby script/parser_coverage.rb upkeep     # one phase, split into effect families
#   bundle exec ruby script/parser_coverage.rb upkeep --lines   # also two example lines per family
#
# A line counts as supported when any Magic::CardParser::Rule parses it (reminder text
# stripped, own name replaced with "~"). That is recognition only, not "generates loadable
# code", and the families are regexes: counts are approximate, a planning aid like
# script/coverage.rb. "sole" = faces whose only unparsed line is that one, i.e. fully
# unlocked by fixing it.

require "bundler/setup"
require_relative "../lib/magic"

PHASES = {
  "upkeep" => /upkeep/,
  "draw" => /draw step/,
  "first_main" => /(precombat|first) main/,
  "second_main" => /(postcombat|second) main/,
  "combat" => /beginning of (each )?combat|of combat on/,
  "end_step" => /end step/
}.freeze

# Effect body (the text after "At the beginning of ..., ") -> family, first match wins.
FAMILIES = [
  ["Sacrifice/tap ~ unless you pay, discard or sacrifice", /\A(sacrifice|tap) ~ unless you /],
  ["Put/remove a counter on ~", /\A(you may )?(put|remove) (a|an|one|two|\d+) [+\w\/-]+ counters? (on|from) (~|it)/],
  ["Counters on other permanents", /counters? on /],
  ["~ deals damage to you / each creature and player", /\A~ deals .+ damage to (you|each)/],
  ["You may pay ... if you do", /\Ayou may pay /],
  ["Intervening if / unless", /\A(if|unless) /],
  ["Exile/look at/reveal top of a library", /\A(you may )?(exile|look at|reveal) the top/],
  ["Create a token", /\Acreate /],
  ["You lose/gain life", /\Ayou (lose|gain) /],
  ["Each opponent / target opponent / each player", /\A(each|target) (opponent|player)/],
  ["Modal (choose one)", /\Achoose /],
  ["Sacrifice a creature/permanent", /\Asacrifice /],
  ["Draw / discard", /\A(you may )?(draw|discard)/],
  ["Coin flip / die roll", /\A(flip|roll) /],
  ["Return / bounce / transform", /\A(return|transform|~ phases out)/]
].freeze

def clean(line, name) = line.gsub(/\s*\([^)]*\)/, "").strip.gsub(name, "~").gsub(Magic::CardParser::THIS_OBJECT, "~")

def faces
  Magic::Oracle.new.all_cards.reject { _1["layout"].to_s.match?(/token|emblem|art_series|vanguard|scheme|planar/) || _1["type_line"].to_s.start_with?("Basic Land") }
               .flat_map { |card| card["card_faces"] || [card] }
end

phase = ARGV.reject { _1.start_with?("--") }.first
show_lines = ARGV.include?("--lines")
abort "unknown phase #{phase.inspect}; one of #{PHASES.keys.join(', ')}" if phase && !PHASES.key?(phase)

rules = Magic::CardParser::Rule.all
total = parsed = whole_faces = face_count = 0
by_phase = Hash.new { |h, k| h[k] = { total: 0, parsed: 0, sole: 0 } }
families = Hash.new { |h, k| h[k] = { lines: 0, sole: 0, examples: [] } }

faces.each do |face|
  lines = (face["oracle_text"] || "").lines.map { clean(_1, face["name"]) }.reject(&:empty?)
  bad = lines.reject { |line| rules.any? { |rule| (rule.parse(line) rescue nil) } }
  face_count += 1
  total += lines.size
  parsed += lines.size - bad.size
  whole_faces += 1 if bad.empty?

  lines.each do |line|
    next unless line.start_with?("At the beginning of")

    clause, body = line.split(", ", 2)
    name, = PHASES.find { |_, re| re.match?(clause.downcase) }
    next unless name

    stats = by_phase[name]
    stats[:total] += 1
    stats[:parsed] += 1 unless bad.include?(line)
    next unless bad.include?(line)

    stats[:sole] += 1 if bad.size == 1
    next unless name == phase

    family = FAMILIES.find { |_, re| re.match?(body.to_s.downcase) }&.first || "Other"
    entry = families[family]
    entry[:lines] += 1
    entry[:sole] += 1 if bad.size == 1
    entry[:examples] << line if entry[:examples].size < 2
  end
end

if phase
  stats = by_phase[phase]
  puts "#{phase}: #{stats[:total]} lines, #{stats[:parsed]} parsed, #{stats[:total] - stats[:parsed]} not, #{stats[:sole]} sole"
  puts "lines\tsole\tfamily"
  families.sort_by { |_, v| -v[:lines] }.each do |name, v|
    puts "#{v[:lines]}\t#{v[:sole]}\t#{name}"
    v[:examples].each { puts "\t\t- #{_1[0, 150]}" } if show_lines
  end
else
  puts "faces: #{face_count}, fully recognised: #{whole_faces} (#{(100.0 * whole_faces / face_count).round(1)}%; vanilla faces count)"
  puts "rules lines: #{total}, recognised: #{parsed} (#{(100.0 * parsed / total).round(1)}%)"
  puts
  puts "\"At the beginning of ...\" lines by phase"
  puts "phase\tlines\tparsed\tnot\tsole"
  by_phase.sort_by { |_, v| -v[:total] }.each do |name, v|
    not_parsed = v[:total] - v[:parsed]
    puts "#{name}\t#{v[:total]}\t#{v[:parsed]}\t#{not_parsed}\t#{v[:sole]}"
  end
end
