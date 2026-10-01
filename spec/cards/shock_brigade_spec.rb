# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShockBrigade do
  include_context "two player game"

  let!(:brigade) { ResolvePermanent("Shock Brigade", owner: p1) }
  def warriors = p1.creatures.select { _1.name == "Warrior" }

  it "is a 1/3 with menace" do
    expect([brigade.power, brigade.toughness]).to eq([1, 3])
    expect(brigade).to have_keyword(Magic::Cards::Keywords::MENACE)
  end

  it "mobilizes 1 when it attacks, and the Warrior is sacrificed at end of turn" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: brigade, target: p2)
    current_turn.attackers_declared!
    expect(warriors.size).to eq(1)
    expect(warriors.first).to be_tapped

    go_to_combat_damage!
    expect(p2.life).to eq(18)
    current_turn.end!
    game.settle!
    expect(warriors).to be_empty
  end
end
