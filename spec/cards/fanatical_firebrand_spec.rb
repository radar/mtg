# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FanaticalFirebrand do
  include_context "two player game"

  let!(:firebrand) { ResolvePermanent("Fanatical Firebrand", owner: p1, summoning_sick: true) }

  before { game.tick! }

  it "is a 1/1 with haste" do
    expect([firebrand.power, firebrand.toughness]).to eq([1, 1])
    expect(firebrand).to be_haste
  end

  it "taps and sacrifices itself to deal 1 damage to any target" do
    p1.activate_ability(ability: firebrand.activated_abilities.first) { _1.targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(19)
    expect(firebrand.card.zone).to be_graveyard
  end

  it "can target a creature" do
    rival = ResolvePermanent("Bear Cub", owner: p2)
    ResolvePermanent("Bear Cub", owner: p2)
    p1.activate_ability(ability: firebrand.activated_abilities.first) { _1.targeting(rival) }
    game.stack.resolve!

    expect(rival.damage).to eq(1)
  end
end
