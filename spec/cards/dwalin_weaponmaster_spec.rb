# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DwalinWeaponmaster do
  include_context "two player game"

  let!(:sword) { ResolvePermanent("Short Sword", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opp_sword) { ResolvePermanent("Short Sword", owner: p2) }

  def hones(equipment) = equipment.counters.of_type(Magic::Counters::Hone).count

  before do
    sword.attach_to!(bears)
    game.tick!
  end

  it "is a 2/1 first strike legendary Dwarf Warrior" do
    dwalin = ResolvePermanent("Dwalin, Weaponmaster", owner: p1)
    expect([dwalin.power, dwalin.toughness]).to eq([2, 1])
    expect(dwalin.has_keyword?(Magic::Cards::Keywords::FIRST_STRIKE)).to eq(true)
  end

  it "puts a hone counter on each Equipment you control when it enters, which grants +1/+0" do
    ResolvePermanent("Dwalin, Weaponmaster", owner: p1)
    game.tick!
    expect(hones(sword)).to eq(1)
    expect(hones(opp_sword)).to eq(0)
    expect([bears.power, bears.toughness]).to eq([4, 3])
  end

  it "adds another hone counter whenever it attacks" do
    dwalin = ResolvePermanent("Dwalin, Weaponmaster", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: dwalin, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect(hones(sword)).to eq(2)
    expect(bears.power).to eq(5)
  end
end
