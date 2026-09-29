# frozen_string_literal: true

# Roadmap L1: which cards of a set have no lib/magic/cards/ file yet, and what mechanic
# stands in the way of auto-generating one. Feeds prioritisation for K and E1.
#
#   bundle exec ruby script/coverage.rb ecl          # tally per mechanic, unimplemented cards only
#   bundle exec ruby script/coverage.rb ecl --lines   # also list each mechanic's failing lines
#   bundle exec ruby script/coverage.rb ecl --cards   # also list every unimplemented card and why
#
# "Implemented" means Magic::Cards defines a constant for the card's name (CardGenerator's
# own naming convention) -- true whether the file was hand-written or produced by
# `rake parse_card`. A card that's already implemented but whose Oracle text the parser
# itself still can't reproduce doesn't show up here; that's script/parser_gaps.rb's question
# (the two scripts share their card-to-mechanic tagging, see mechanic_tags.rb).
#
# Adventure/split/transform cards are looked up by either face's name (Scryfall's combined
# "Front // Back" name is split), so a double-faced card counts once its front (or back) face
# class exists. A planning aid, not a parser, same caveat as parser_gaps.rb.

require "bundler/setup"
require_relative "../lib/magic"
require_relative "mechanic_tags"

set_code = ARGV.reject { _1.start_with?("--") }.first or abort "usage: coverage.rb <set code> [--lines] [--cards]"
show_lines = ARGV.include?("--lines")
show_cards = ARGV.include?("--cards")

by_card = card_faces_for(set_code).group_by { _1[:card] }

implemented, unimplemented = by_card.keys.partition { |name| name.split(" // ").any? { |face| Magic::Cards.const_defined?(Magic::CardGenerator.const_name(face)) } }

puts "#{set_code}: #{by_card.size} cards; #{implemented.size} implemented, #{unimplemented.size} are not"
puts

# A card whose faces would all generate cleanly is tagged "ready to generate" instead of by
# mechanic -- these are the cheapest to pick up (rake parse_card and go). One tagged with a
# real mechanic still might generate for its *other* face (a land side of an adventure card,
# say); "sole" below counts a card as blocked by one thing only if every face that fails
# fails for that one reason.
tagged = unimplemented.map do |name|
  blocked = by_card[name].filter_map { |face| (result = tag_face(face)) && [face, result] }
  if blocked.empty?
    { card: name, tags: ["Ready to generate (rake parse_card)"], lines: [] }
  else
    { card: name, tags: blocked.flat_map { |_, result| result[:tags] }.uniq, lines: blocked.flat_map { |_, result| result[:lines] }.uniq }
  end
end

by_tag = Hash.new { |h, k| h[k] = [] }
tagged.each { |t| t[:tags].each { |tag| by_tag[tag] << t } }

puts "cards\tsole\tmechanic"
by_tag.sort_by { |_, ts| -ts.size }.each do |tag, ts|
  puts "#{ts.size}\t#{ts.count { _1[:tags].size == 1 }}\t#{tag}"
  next unless show_lines

  ts.flat_map { _1[:lines] }.uniq.first(8).each { |l| puts "\t\t  - #{l[0, 160]}" }
end

if show_cards
  puts "\nunimplemented cards and their blockers:"
  tagged.sort_by { _1[:card] }.each { |t| puts "#{t[:card]} — #{t[:tags].join('; ')}" }
end
