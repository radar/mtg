# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UtterInsignificance do
  include_context "two player game"

  let!(:dragon) { ResolvePermanent("Serra Angel", owner: p2) }

  before do
    go_to_main_phase!
    p1.add_mana(blue: 2)
    p1.cast(card: Card("Utter Insignificance", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(dragon) }
    game.stack.resolve!
    game.settle!
    game.tick!
  end

  def aura = game.battlefield.permanents.find { _1.name == "Utter Insignificance" }

  it "makes the creature 1/1 and strips its abilities" do
    expect([dragon.power, dragon.toughness]).to eq([1, 1])
    expect(dragon.flying?).to eq(false)
  end

  it "can exile the enchanted creature for {2}{C}" do
    p1.add_mana(generic: 0, colorless: 3)
    p1.activate_ability(ability: aura.activated_abilities.first) { |a| a.pay_mana(generic: { colorless: 2 }, colorless: 1) }
    game.stack.resolve!
    game.settle!

    expect(game.exile.cards.map(&:name)).to include("Serra Angel")
  end
end
