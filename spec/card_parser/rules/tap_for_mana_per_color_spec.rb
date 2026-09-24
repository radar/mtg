# frozen_string_literal: true

require "spec_helper"
require_relative "../card_parser_helpers"

RSpec.describe Magic::CardParser::Rules::TapForManaPerColor do
  include CardParserHelpers
  include_context "two player game"

  it "parses the Vivid mana ability, dropping the ability word" do
    expect(described_class.parse("{T}: For each color among permanents you control, add one mana of that color.")).not_to be_nil
    source = generate("Parsed Tender {1}{G}\nCreature — Elf Druid\nVivid — {T}: For each color among permanents you control, add one mana of that color.\n1/1\n")
    expect(source).to include("class ManaAbility < Magic::TapManaAbility", "source.controller.permanents.flat_map(&:colors).uniq")
  end

  it "adds one mana of each color among your permanents" do
    load_card("Parsed Tender {1}{G}\nCreature — Elf Druid\nVivid — {T}: For each color among permanents you control, add one mana of that color.\n1/1\n")
    tender = ResolvePermanent("Parsed Tender", owner: p1)
    ResolvePermanent("Liminal Hold", owner: p1)
    p1.activate_ability(ability: tender.activated_abilities.first)

    expect(p1.mana_pool.select { _2.positive? }).to eq(green: 1, white: 1)
  end
end
