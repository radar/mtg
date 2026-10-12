# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BoltHound do
  include_context "two player game"

  let!(:hound) { ResolvePermanent("Bolt Hound", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "is a 2/2 Elemental Dog with haste" do
    expect([hound.power, hound.toughness]).to eq([2, 2])
    expect(hound).to be_haste
  end

  it "gives your other creatures +1/+0 when it attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: hound, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect(bears.power).to eq(3)
    expect(hound.power).to eq(2)
    expect(theirs.power).to eq(2)
  end

  it "doesn't trigger when another creature attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bears, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect(bears.power).to eq(2)
  end
end
