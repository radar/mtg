# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AdventuringGear do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:gear) { ResolvePermanent("Adventuring Gear", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "can equip for {1}" do
    p1.add_mana(white: 1)
    p1.activate_ability(ability: gear.activated_abilities.first) { _1.pay_mana(generic: { white: 1 }).targeting(bears) }
    game.stack.resolve!

    expect(gear.attached_to).to eq(bears)
  end

  it "gives the equipped creature +2/+2 until end of turn when a land enters under your control" do
    gear.attach_to!(bears)
    p1.play_land(land: Card("Forest", owner: p1))
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "does nothing when an opponent's land enters" do
    gear.attach_to!(bears)
    go_to_main_phase_for!(p2)
    p2.play_land(land: Card("Mountain", owner: p2))
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 2])
  end
end
