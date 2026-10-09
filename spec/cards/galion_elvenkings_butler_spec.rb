# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GalionElvenkingsButler do
  include_context "two player game"

  let!(:galion) { ResolvePermanent("Galion Elvenkings Butler", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Elvish Mystic", owner: p1) }

  def attack
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: galion, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 4/4 legendary Elf Advisor" do
    expect([galion.power, galion.toughness]).to eq([4, 4])
    expect(galion.type?("Elf")).to eq(true)
  end

  it "sets another target creature's base power and toughness to Galion's when it attacks" do
    attack
    game.resolve_choice!(target: bears)
    game.tick!
    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect([other.power, other.toughness]).to eq([1, 1])
  end

  it "may choose no target" do
    attack
    game.skip_choice!
    game.tick!
    expect([bears.power, bears.toughness]).to eq([2, 2])
  end
end
