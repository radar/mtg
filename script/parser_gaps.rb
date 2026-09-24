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

set_code = ARGV.reject { _1.start_with?("--") }.first or abort "usage: parser_gaps.rb <set code> [--lines]"
show_lines = ARGV.include?("--lines")

MECHANICS = [
  ["Changeling", /\AChangeling|with changeling|all creature types|has changeling|except it has changeling/],
  ["Convoke", /convoke/i],
  ["Evoke", /\AEvoke/],
  ["Blight", /\bblights?\b/i],
  ["Behold", /\bbehold\b/i],
  ["Vivid", /\AVivid/],
  ["Mana spent to cast (\"if {R}{R} was spent to cast it\")", /was spent to cast/],
  ["Pay-to-transform / double-faced cards", /transform/i],
  ["Choose a creature type (chosen-type effects)", /choose (a|an) creature type|As ~ enters, choose|of the chosen type|chosen type|is the chosen color/i],
  ["Legacy keywords (persist, wither, conspire, affinity)", /\A(Wither|Affinity)|persist|conspire|wither/i],
  ["Cycling variants (landcycling)", /cycling/i],
  ["Ward with non-mana costs", /ward/i],
  ["Planeswalker loyalty abilities", /\A[+−-]\d+: |\A[+−-]X: /],
  ["Modal spells / modal ETB", /choose one|\A•|choose two/i],
  ["Alternative / additional casting costs and cast permissions", /additional cost|costs? \{[^}]+\} less|costs? .* less to cast|as though it had flash|exile ~ from your graveyard|from among cards|Once each turn, you may cast/i],
  ["Counter mechanics (remove any, charge, dream, stun, no-counters)", /Remove (a|two|three|any number of|\w+) counters?|stun counter|charge counter|dream counter|can't have counters/],
  ["-1/-1 counter interactions", /-\d+\/-\d+ counter/],
  ["Treasure tokens", /Treasure/],
  ["Tokens with unsupported shape (copies, Shapeshifter, conditional counts)", /token/i],
  ["Copy effects (permanents, spells, abilities)", /\bcopy\b|copies|becomes a copy/i],
  ["Counterspells", /\ACounter |Counter target|Counter all|can't be countered/],
  ["Surveil", /surveil/i],
  ["Mill", /\bmill\b/i],
  ["Look at the top N cards (dig)", /look at the top/i],
  ["Exile from top of a library, may play/cast", /exile the top|exiles? cards from the top|from the top of your library/i],
  ["Tuck / put a permanent into its owner's library", /second from the top|puts it (into|on)/i],
  ["Graveyard recursion / reanimation / put onto battlefield from hand", /graveyard|from your hand onto the battlefield/],
  ["Bounce / blink / exile effects", /owner's hand|Exile target creature you control, then return|Exile any number|return those cards|\AExile ~/i],
  ["Complex mana abilities (spend-only, X, any combination, tap-creature costs)", /Add (X|two mana|one mana of any)|Spend this mana|adds (an additional|one mana)|Add \{[A-Z]\}\{[A-Z]\}\{[A-Z]\}\{[A-Z]\}|Tap an untapped creature/],
  ["Extra land drops", /additional land/],
  ["Tribal-qualified triggers/effects (Goblin, Elf, Kithkin, ...)", /(Goblin|Elf|Elves|Elemental|Faerie|Merfolk|Kithkin|Giant|Treefolk|Shapeshifter)s? (you control|creature)|another (Elf|Elemental|Kithkin|Goblin|Merfolk)|Whenever (~|\w+) or another|untap target Merfolk/i],
  ["Tap/untap triggers and tap-creature costs", /becomes tapped|\bUntap\b|\bTap (up to|target|two|three|an|it)|Tap .* untapped/],
  ["Conditional attack/block triggers", /attacks alone|attacks or blocks|attacking or blocking|Whenever ~ attacks|Whenever a creature you control attacks/],
  ["Casting triggers with conditions", /Whenever you cast|when you next cast/],
  ["Combat restrictions & evasion (can't block, must be blocked, can't attack)", /can't (block|attack|be blocked|become untapped)|must be blocked/],
  ["Conditional static keywords/abilities (as long as, during your turn)", /as long as|During your turn|hexproof|double strike|indestructible|have haste|Other tapped|first strike|All creatures have/i],
  ["X-based / count-based pump", /where X is|gets? [+-]\d+\/[+-]\d+|get \+X|gets \+X|\+X\/\+X/],
  ["Global replacement / prevention effects", /prevent all damage|Players can't|Double all damage|triggers an additional time/i],
  ["Removal variants (destroy attacking/blocking, edicts)", /Destroy target|sacrifices all other|Each player sacrifices/],
  ["ETB/dies triggers with unsupported effects", /When(ever)? ~ (enters|dies|leaves)|When(ever)? .* (enters|dies)/],
  ["Life / damage / draw compound effects", /deals? .*damage|lose[s]? \d+ life|gain \d+ life|draw|discard/i],
  ["Aura/equipment restrictions and characteristic setting", /Enchanted|Equipped/],
  ["Activated abilities with limits or non-cost restrictions", /Activate only once each turn|^\{/],
  ["P/T with * (characteristic-defining)", %r{\A\*/}],
].freeze
OTHER = "Unclassified"

def card_text(face) = [ "#{face[:name]} #{face[:cost]}".strip, face[:type], face[:text], face[:pt] ].compact.join("\n")

faces = Magic::Oracle.new.cards_in_set(set_code).flat_map do |card|
  (card["card_faces"] || [card]).filter_map do |f|
    next if f["type_line"].to_s.start_with?("Basic Land")

    { card: card["name"], name: f["name"], cost: f["mana_cost"], type: f["type_line"],
      text: f["oracle_text"] || card["oracle_text"].to_s, pt: (f["power"] ? "#{f['power']}/#{f['toughness']}" : nil) }
  end
end

supported = 0
failing = []
faces.each do |face|
  Magic::CardGenerator.generate(Magic::CardParser.parse(card_text(face)))
  supported += 1
rescue StandardError
  lines = card_text(face).lines.drop(2).map { |l| l.gsub(/\s*\([^)]*\)/, "").strip }.reject(&:empty?)
  lines.pop if lines.last&.match?(Magic::CardParser::PT)
  lines = lines.map { |l| l.gsub(face[:name], "~").gsub(Magic::CardParser::THIS_OBJECT, "~") }
  unparsed = lines.select { |l| Magic::CardParser::Rule.all.none? { |rule| (rule.parse(l) rescue nil) } }
  tags = unparsed.map { |l| (MECHANICS.find { |_, re| re.match?(l) } || [OTHER]).first }
  tags << "Kindred type line" if face[:type].match?(/\bKindred\b/)
  tags << "Planeswalker card kind" if face[:type].include?("Planeswalker")
  tags << "Legendary enchantment" if face[:type].start_with?("Legendary Enchantment")
  failing << face.merge(lines: unparsed, tags: tags.uniq)
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
