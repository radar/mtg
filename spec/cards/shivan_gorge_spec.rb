# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShivanGorge do
  include_context "two player game"

  let!(:gorge) { ResolvePermanent("Shivan Gorge", owner: p1) }

  it "is a legendary land that taps for {C}" do
    expect(gorge.card).to be_legendary
    p1.activate_ability(ability: gorge.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(1)
  end

  it "deals 1 damage to each opponent for {2}{R} and tapping" do
    p1.add_mana(red: 3)
    p1.activate_ability(ability: gorge.activated_abilities.last) { _1.pay_mana(generic: { red: 2 }, red: 1) }
    game.stack.resolve!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end
end
