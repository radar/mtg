# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EnduringVitality do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:vitality) { ResolvePermanent("Enduring Vitality", owner: p1) }

  it "is a 3/3 Enchantment Creature with vigilance" do
    expect([vitality.power, vitality.toughness]).to eq([3, 3])
    expect(vitality.type?("Enchantment")).to be(true)
    expect(vitality).to have_keyword(:vigilance)
  end

  it "lets creatures you control tap for one mana of any color" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    ability = bear.activated_abilities.first
    expect(ability).not_to be_nil
    p1.activate_ability(ability: ability) { |a| a.choose(:red) }

    expect(p1.mana_pool[:red]).to eq(1)
    expect(bear).to be_tapped
  end

  it "does not grant the ability to opponent's creatures" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect(bear.activated_abilities).to be_empty
  end

  it "returns as a non-creature enchantment when it dies as a creature" do
    vitality.destroy!
    game.settle!

    returned = game.battlefield.cards.by_name("Enduring Vitality").first
    expect(returned).not_to be_nil
    expect(returned.creature?).to be(false)
    expect(returned.type?("Enchantment")).to be(true)
  end
end
