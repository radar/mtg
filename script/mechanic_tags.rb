# frozen_string_literal: true

# Shared by script/parser_gaps.rb and script/coverage.rb: turning a set's Oracle cards into
# per-face text, and tagging a face's unparseable lines by the mechanic that blocks them.
# Buckets are approximate: they are a planning aid, not a parser.

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

# Every non-basic-land face of the set, each as its own hash: {card:, name:, cost:, type:,
# text:, pt:}. `card:` is the whole card's name (what lib/magic/cards/ files are keyed on);
# `name:` is this face's own name (differs from `card:` for adventure/split/transform/MDFCs).
def card_faces_for(set_code)
  Magic::Oracle.new.cards_in_set(set_code).flat_map do |card|
    (card["card_faces"] || [card]).filter_map do |f|
      next if f["type_line"].to_s.start_with?("Basic Land")

      { card: card["name"], name: f["name"], cost: f["mana_cost"], type: f["type_line"],
        text: f["oracle_text"] || card["oracle_text"].to_s, pt: (f["power"] ? "#{f['power']}/#{f['toughness']}" : nil) }
    end
  end
end

def card_text(face) = [ "#{face[:name]} #{face[:cost]}".strip, face[:type], face[:text], face[:pt] ].compact.join("\n")

# Attempts to parse+generate the face; returns nil on success, or {lines:, tags:} describing
# what blocked it (see MECHANICS) if not.
def tag_face(face)
  Magic::CardGenerator.generate(Magic::CardParser.parse(card_text(face)))
  nil
rescue StandardError
  lines = card_text(face).lines.drop(2).map { |l| l.gsub(/\s*\([^)]*\)/, "").strip }.reject(&:empty?)
  lines.pop if lines.last&.match?(Magic::CardParser::PT)
  lines = lines.map { |l| l.gsub(face[:name], "~").gsub(Magic::CardParser::THIS_OBJECT, "~") }
  unparsed = lines.select { |l| Magic::CardParser::Rule.all.none? { |rule| (rule.parse(l) rescue nil) } }
  tags = unparsed.map { |l| (MECHANICS.find { |_, re| re.match?(l) } || [OTHER]).first }
  tags << "Kindred type line" if face[:type].match?(/\bKindred\b/)
  tags << "Planeswalker card kind" if face[:type].include?("Planeswalker")
  tags << "Legendary enchantment" if face[:type].start_with?("Legendary Enchantment")
  { lines: unparsed, tags: tags.uniq }
end
