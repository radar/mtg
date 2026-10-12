# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LionheartGlimmer do
  include_context "two player game"

  let!(:glimmer) { ResolvePermanent("Lionheart Glimmer", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 2/5 with ward {2}" do
    expect([glimmer.power, glimmer.toughness]).to eq([2, 5])
    expect(glimmer.type?("Enchantment")).to be(true)
  end

  it "gives creatures you control +1/+1 when you attack" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bears, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect([glimmer.power, glimmer.toughness]).to eq([3, 6])
    expect(theirs.power).to eq(2)
  end

  it "does nothing when no creature attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect(bears.power).to eq(2)
  end
end
