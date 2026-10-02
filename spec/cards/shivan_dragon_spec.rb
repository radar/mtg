# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShivanDragon do
  include_context "two player game"

  let!(:dragon) { ResolvePermanent("Shivan Dragon", owner: p1) }

  it "is a 5/5 flying Dragon" do
    expect([dragon.power, dragon.toughness]).to eq([5, 5])
    expect(dragon).to be_flying
  end

  it "gets +1/+0 until end of turn for each {R}" do
    p1.add_mana(red: 3)
    3.times do
      p1.activate_ability(ability: dragon.activated_abilities.first) { _1.pay_mana(red: 1) }
      game.stack.resolve!
    end
    game.tick!

    expect([dragon.power, dragon.toughness]).to eq([8, 5])
  end

  it "wears off at end of turn" do
    p1.add_mana(red: 1)
    p1.activate_ability(ability: dragon.activated_abilities.first) { _1.pay_mana(red: 1) }
    game.stack.resolve!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(dragon.power).to eq(5)
  end
end
