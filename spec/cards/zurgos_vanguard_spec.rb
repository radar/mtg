# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ZurgosVanguard do
  include_context "two player game"

  let!(:vanguard) { ResolvePermanent("Zurgo's Vanguard", owner: p1) }
  def warriors = p1.creatures.select { _1.name == "Warrior" }

  it "has power equal to the number of creatures you control" do
    game.tick!
    expect([vanguard.power, vanguard.toughness]).to eq([1, 3])
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!
    expect(vanguard.power).to eq(2)
  end

  it "mobilizes 1 when it attacks, growing as the Warrior arrives" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: vanguard, target: p2)
    current_turn.attackers_declared!
    game.tick!

    expect(warriors.size).to eq(1)
    expect(vanguard.power).to eq(2)
  end
end
