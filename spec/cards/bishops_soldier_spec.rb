# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BishopsSoldier do
  include_context "two player game"

  let!(:soldier) { ResolvePermanent("Bishop's Soldier", owner: p1) }

  it "is a 2/2 lifelinker" do
    expect([soldier.power, soldier.toughness]).to eq([2, 2])
    expect(soldier).to be_lifelink
  end

  it "gains its controller life when it deals damage" do
    rival = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(soldier, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(rival, attacker: soldier)
    current_turn.combat_damage!
    game.settle!

    expect(p1.life).to eq(22)
  end
end
