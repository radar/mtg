# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlameChainMauler do
  include_context "two player game"

  let!(:mauler) { ResolvePermanent("Flame-Chain Mauler", owner: p1) }

  it "is a 2/2 elemental warrior" do
    expect(mauler.card.types).to include("Elemental", "Warrior")
    expect(mauler.power).to eq(2)
    expect(mauler.toughness).to eq(2)
  end

  it "gets +1/+0 and gains menace until end of turn for {1}{R}" do
    p1.add_mana(red: 2)

    p1.activate_ability(ability: mauler.activated_abilities.first) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }
    game.stack.resolve!

    expect(mauler.power).to eq(3)
    expect(mauler.toughness).to eq(2)
    expect(mauler.menace?).to be(true)
  end
end
