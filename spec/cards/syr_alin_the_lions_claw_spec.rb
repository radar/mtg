# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SyrAlinTheLionsClaw do
  include_context "two player game"

  let!(:alin) { ResolvePermanent("Syr Alin, The Lion's Claw", owner: p1) }
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

  it "is a 4/4 legendary Human Knight with first strike" do
    expect([alin.power, alin.toughness]).to eq([4, 4])
    expect(alin).to be_first_strike
  end

  it "gives other creatures you control +1/+1 when it attacks" do
    attack_with(alin)

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect([alin.power, alin.toughness]).to eq([4, 4])
    expect([rival.power, rival.toughness]).to eq([2, 2])
  end

  it "doesn't trigger when another creature attacks" do
    attack_with(bears)

    expect(bears.power).to eq(2)
  end
end
