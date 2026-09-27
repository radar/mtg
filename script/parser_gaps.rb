# frozen_string_literal: true

# Which cards of a set can't yet go through Magic::CardParser + Magic::CardGenerator, and
# which mechanics stand in the way. Used to plan parser work (see docs/ecl_parser_gaps.md).
#
#   bundle exec ruby script/parser_gaps.rb ecl          # tally per mechanic
#   bundle exec ruby script/parser_gaps.rb ecl --lines  # also list each mechanic's failing lines
#   bundle exec ruby script/parser_gaps.rb ecl --cards  # also list every failing face with its blockers
#
# Each face of a card is parsed on its own. A face that fails has its rules lines tried one by
# one against every Rule; the lines no rule accepts are sorted into mechanic buckets by the
# regexes in MECHANICS (first match wins), and card-level structure (hybrid mana, Kindred,
# planeswalkers, ...) adds a few more. Buckets are approximate: they are a planning aid, not
# a parser. A mechanic is "sole" when it is the only thing blocking a card.

require "bundler/setup"
require_relative "../lib/magic"
require_relative "mechanic_tags"

set_code = ARGV.reject { _1.start_with?("--") }.first or abort "usage: parser_gaps.rb <set code> [--lines]"
show_lines = ARGV.include?("--lines")

faces = card_faces_for(set_code)

supported = 0
failing = []
faces.each do |face|
  result = tag_face(face)
  if result
    failing << face.merge(result)
  else
    supported += 1
  end
end

puts "#{set_code}: #{faces.size} faces (#{faces.map { _1[:card] }.uniq.size} cards); #{supported} generate cleanly, #{failing.size} do not"
puts "blockers per failing face: 1 => #{failing.count { _1[:tags].size == 1 }}, <=2 => #{failing.count { _1[:tags].size <= 2 }}, <=3 => #{failing.count { _1[:tags].size <= 3 }}"
puts
by_tag = Hash.new { |h, k| h[k] = [] }
failing.each { |f| f[:tags].each { |t| by_tag[t] << f } }
puts "faces\tsole\tmechanic"
by_tag.sort_by { |_, fs| -fs.size }.each do |tag, fs|
  puts "#{fs.size}\t#{fs.count { _1[:tags].size == 1 }}\t#{tag}"
  next unless show_lines

  fs.flat_map { _1[:lines] }.select { |l| (MECHANICS.find { |_, re| re.match?(l) } || [OTHER]).first == tag }.uniq.first(8).each { puts "\t\t  - #{l = _1[0, 160]}" }
end

if ARGV.include?("--cards")
  puts "\nfailing faces and their blockers:"
  failing.sort_by { _1[:name] }.each { |f| puts "#{f[:name]} — #{f[:tags].join('; ')}" }
end

# Greedy order: repeatedly take the mechanic that completes the most faces.
puts "\ngreedy order (faces newly unlocked / cumulative):"
done = []
loop do
  gains = Hash.new(0)
  failing.each do |f|
    open = f[:tags] - done
    gains[open.first] += 1 if open.size == 1
  end
  best = gains.max_by { _2 } or break
  done << best[0]
  puts "#{done.size}\t+#{best[1]}\t#{failing.count { (_1[:tags] - done).empty? }}\t#{best[0]}"
end
