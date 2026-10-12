# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DinIronfoot do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:dain) { ResolvePermanent("Dáin Ironfoot", owner: p1) }
  let(:axe) { p1.permanents.find { _1.name == "Axe" } }

  it "is a 1/4 legendary Dwarf Warrior" do
    expect([dain.power, dain.toughness]).to eq([1, 4])
    expect(dain.type?("Dwarf")).to eq(true)
  end

  it "creates an Axe token and attaches it to a creature you control" do
    expect(axe).not_to be_nil
    game.resolve_choice!(target: bears)
    game.tick!
    expect(axe.attached_to).to eq(bears)
    expect([bears.power, bears.toughness]).to eq([3, 2])
  end

  it "gives each equipped attacking creature double strike when Dáin attacks" do
    game.resolve_choice!(target: bears)
    game.tick!
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: dain, target: p2)
    p1.declare_attacker(attacker: bears, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect(bears.has_keyword?(Magic::Cards::Keywords::DOUBLE_STRIKE)).to eq(true)
    expect(dain.has_keyword?(Magic::Cards::Keywords::DOUBLE_STRIKE)).to eq(false)
  end
end
