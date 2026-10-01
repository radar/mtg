# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SunsetStrikemaster do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:strikemaster) { ResolvePermanent("Sunset Strikemaster", owner: p1) }

  it "is a 3/1" do
    expect([strikemaster.power, strikemaster.toughness]).to eq([3, 1])
  end

  it "taps for red" do
    p1.activate_ability(ability: strikemaster.activated_abilities.first)
    expect(p1.mana_pool[:red]).to eq(1)
    expect(strikemaster).to be_tapped
  end

  it "sacrifices itself to deal 6 damage to a creature with flying" do
    angel = ResolvePermanent("Baneslayer Angel", owner: p2)
    p1.add_mana(red: 3)
    ability = strikemaster.activated_abilities.last
    p1.activate_ability(ability: ability) { |a| a.pay_mana(red: 1, generic: { red: 2 }).targeting(angel) }
    game.stack.resolve!
    game.settle!

    expect(p1.graveyard.cards.map(&:name)).to include("Sunset Strikemaster")
    expect(p2.graveyard.cards.map(&:name)).to include("Baneslayer Angel")
  end

  it "cannot target a creature without flying" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ability = strikemaster.activated_abilities.last
    p1.add_mana(red: 3)
    expect do
      p1.activate_ability(ability: ability) { |a| a.pay_mana(red: 1, generic: { red: 2 }).targeting(bears) }
    end.to raise_error(StandardError)
  end
end
