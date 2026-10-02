# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GorehornRaider do
  include_context "two player game"

  def attack_with_a_creature!
    attacker = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    current_turn.attackers_declared!
    attacker
  end

  it "is a 4/4 Minotaur Pirate" do
    raider = ResolvePermanent("Gorehorn Raider", owner: p1, settle: false)

    expect([raider.power, raider.toughness]).to eq([4, 4])
    expect(raider.type?("Pirate")).to be(true)
  end

  it "deals 2 damage to any target when it enters if you attacked this turn (raid)" do
    attack_with_a_creature!
    ResolvePermanent("Gorehorn Raider", owner: p1)
    game.settle!
    game.resolve_choice!(target: p2)

    expect(p2.life).to eq(18)
  end

  it "can hit a creature" do
    attacker = attack_with_a_creature!
    ResolvePermanent("Gorehorn Raider", owner: p1)
    game.settle!
    game.resolve_choice!(target: attacker)

    expect(attacker.damage).to eq(2)
  end

  it "does nothing when you did not attack this turn" do
    go_to_main_phase!
    ResolvePermanent("Gorehorn Raider", owner: p1)
    game.settle!

    expect(game.choices).to be_empty
    expect(p2.life).to eq(20)
  end
end
