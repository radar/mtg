# frozen_string_literal: true

# Regenerates docs/keywords.md from the Oracle data (`data/oracle-cards-*.jsonl`).
#   bundle exec ruby script/keyword_audit.rb
#
# Scryfall's `keywords` field lists keyword abilities, keyword actions and some ability words.
# Status is curated in the tables below: edit them when engine support changes, then rerun.
require "json"

LAYOUTS = %w[normal saga adventure transform modal_dfc split flip meld leveler class case prototype mutate].freeze

IMPLEMENTED = {
  "Flying" => "cards/keywords.rb; game/combat_phase.rb (block legality)",
  "Reach" => "cards/keywords.rb; game/combat_phase.rb",
  "Trample" => "game/combat_phase.rb (damage assignment)",
  "Vigilance" => "cards/keywords.rb; game/turn.rb (attack tapping)",
  "Haste" => "cards/keywords.rb; Permanent#summoning_sick?",
  "Flash" => "cards/keywords.rb; Actions::Cast legality",
  "Menace" => "game/combat_phase.rb (validate_blocks!)",
  "Skulk" => "game/combat_phase.rb",
  "First strike" => "game/combat_phase.rb (deal_first_strike_damage)",
  "Double strike" => "game/combat_phase.rb",
  "Deathtouch" => "effects/deal_combat_damage.rb; game/state_based_actions.rb",
  "Lifelink" => "effects/deal_combat_damage.rb",
  "Defender" => "cards/keywords.rb; Actions::DeclareAttacker legality",
  "Infect" => "effects/deal_combat_damage.rb",
  "Toxic" => "cards/keywords.rb (Toxic); effects/deal_combat_damage.rb",
  "Changeling" => "cards/keywords.rb; types.rb",
  "Prowess" => "cards/keyword_handlers/prowess.rb",
  "Flashback" => "card.rb (flashback); actions/cast.rb",
  "Cycling" => "card.rb (cycling); actions/cycle.rb",
  "Buyback" => "card.rb (buyback); actions/cast.rb",
  "Rebound" => "card.rb (rebound); actions/cast.rb (by_effect)",
  "Landfall" => "triggered_ability/landfall.rb; events/landfall.rb",
  "Equip" => "cards/equipment.rb",
  "Enchant" => "cards/aura.rb; game/state_based_actions.rb (704.5m)",
  "Scry" => "player.rb (scry); events/scry.rb",
  "Surveil" => "player.rb (surveil); choice/surveil.rb",
  "Mill" => "player.rb (mill); zones/library.rb",
  "Treasure" => "tokens/treasure.rb",
  "Food" => "tokens/food.rb",
  "Clue" => "tokens/clue.rb",
  "Investigate" => "tokens/clue.rb",
}.freeze

PARTIAL = {
  "Hexproof" => "Flag only (`Keywords#hexproof?`, `HexproofFrom`). `Permanent#can_be_targeted_by?` is a stub that returns true, so targeting is not blocked. E2.",
  "Shroud" => "Flag only, as Hexproof. E2.",
  "Protection" => "`protection.rb`: enforced for blocking, aura attachment (SBA) and player protection. Not enforced for targeting or damage prevention. E2.",
  "Ward" => "`Card.ward` DSL: reacts to spells (`SpellCast`) only, not abilities; pays through `Choice::Ward`. E2.",
  "Indestructible" => "Checked in SBA and destroy effects. Not modelled as a replacement effect. E3.",
  "Regenerate" => "`Permanent#regenerate!` only taps and clears damage. No shield, no removal from combat. E3.",
  "Kicker" => "`Card.kicker_cost`, `Costs::Kicker`. Single kicker only; no multikicker or variants. E4.",
  "Fight" => "`Creature#fight` helper. No `Effects::Fight`. E6.",
  "Transform" => "`Permanent#transform!` only. No daybound/nightbound, no disturb.",
  "Proliferate" => "`choice/proliferate.rb`, used by one card. No generic effect. E6.",
  "Explore" => "Hand-rolled in one card file. No generic effect. E6.",
  "Echo" => "Hand-rolled in card files. No keyword handler. E5.",
  "Storm" => "Hand-rolled in card files (Grapeshot). No cast-count copy. E6.",
  "Delve" => "One-off in a card file. E4.",
  "Escape" => "One-off in a card file. E4.",
  "Overload" => "One-off in a card file. E4.",
  "Channel" => "One-off in a card file. E4.",
}.freeze

# Ability words, keyword actions and setup text. No engine keyword needed: each card spells out
# its own effect. (Actions with a reusable effect are tracked under E6.)
NOT_APPLICABLE = %w[
  Landcycling Typecycling Conjure Seek Threshold Delirium Domain Metalcraft Morbid Ferocious Corrupted
  Raid Heroic Constellation Magecraft Alliance Enrage Converge Imprint Ascend Blight Heal
  Amass Manifest Connive Goad Populate Bolster Adapt Incubate Discover Clash
  Behold Craft Earthbend Waterbend Firebending Airbend Gift Exhaust Warp Sneak Station Saddle Crew
].freeze

def status_for(keyword)
  return ["implemented", IMPLEMENTED[keyword]] if IMPLEMENTED.key?(keyword)
  return ["partial", PARTIAL[keyword]] if PARTIAL.key?(keyword)
  return ["n.a.", "Ability word, keyword action or setup text; each card spells out its own effect."] if NOT_APPLICABLE.include?(keyword)

  ["missing", ""]
end

counts = Hash.new(0)
File.foreach(Dir[File.expand_path("../data/*.jsonl", __dir__)].first) do |line|
  card = JSON.parse(line)
  next unless LAYOUTS.include?(card["layout"])

  (card["keywords"] || []).each { |keyword| counts[keyword] += 1 }
end

rows = counts.map { |keyword, n| [keyword, n, *status_for(keyword)] }
order = %w[implemented partial missing n.a.]
rows.sort_by! { |keyword, n, status, _| [order.index(status), -n, keyword] }

tally = rows.group_by { |row| row[2] }.transform_values(&:count)
File.open(File.expand_path("../docs/keywords.md", __dir__), "w") do |f|
  f.puts "# Keyword audit"
  f.puts
  f.puts "Generated by `script/keyword_audit.rb` from the Scryfall `keywords` field of the Oracle data. Edit the status tables in the script, not this file."
  f.puts
  f.puts "Paths are relative to `lib/magic/`. **Cards** is the number of Oracle cards that list the keyword."
  f.puts
  f.puts "- implemented: #{tally['implemented']}, partial: #{tally['partial']}, missing: #{tally['missing']}, n.a.: #{tally['n.a.']}"
  f.puts
  order.each do |status|
    section = rows.select { |row| row[2] == status }
    next if section.empty?

    f.puts "## #{status.capitalize} (#{section.size})"
    f.puts
    f.puts "Ordered by card count. No engine support; a card using one hand-rolls it or is unimplemented." if status == "missing"
    f.puts if status == "missing"
    f.puts "| Keyword | Cards | Owner / notes |"
    f.puts "| --- | ---: | --- |"
    section.each { |keyword, n, _, note| f.puts "| #{keyword} | #{n} | #{note} |" }
    f.puts
  end
end
puts tally
