# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DauntlessVeteran do
  include_context "two player game"

  let!(:veteran) { ResolvePermanent("Dauntless Veteran", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!
  end

  it "is a 2/2 Human Soldier" do
    expect([veteran.power, veteran.toughness]).to eq([2, 2])
  end

  it "gives creatures you control +1/+1 when it attacks" do
    attack_with(veteran)

    expect([veteran.power, veteran.toughness]).to eq([3, 3])
    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect([rival.power, rival.toughness]).to eq([2, 2])
  end

  it "doesn't trigger when another creature attacks" do
    attack_with(bears)

    expect(bears.power).to eq(2)
  end
end
