# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ClachanFestival do
  include_context "two player game"
  before { go_to_main_phase! }

  def kithkin_tokens = p1.permanents.select { |permanent| permanent.name == "Kithkin" }

  it "is a Kindred Enchantment — Kithkin" do
    expect(Card("Clachan Festival").types).to include("Enchantment", "Kithkin")
  end

  it "creates two 1/1 green and white Kithkin tokens when it enters" do
    ResolvePermanent("Clachan Festival", owner: p1)

    expect(kithkin_tokens.count).to eq(2)
    expect(kithkin_tokens).to all(have_attributes(power: 1, toughness: 1))
  end

  it "creates another 1/1 Kithkin token for {4}{W}" do
    festival = ResolvePermanent("Clachan Festival", owner: p1)
    p1.add_mana(white: 5)

    p1.activate_ability(ability: festival.activated_abilities.first) { |a| a.pay_mana(generic: { white: 4 }, white: 1) }
    game.stack.resolve!

    expect(kithkin_tokens.count).to eq(3)
  end
end
