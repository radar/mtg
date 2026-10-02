# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StormFleetSpy do
  include_context "two player game"

  def attack_with_a_creature!
    attacker = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: attacker, target: p2)
    current_turn.attackers_declared!
  end

  it "is a 2/2 Human Pirate" do
    spy = ResolvePermanent("Storm Fleet Spy", owner: p1)

    expect([spy.power, spy.toughness]).to eq([2, 2])
    expect(spy.type?("Pirate")).to be(true)
  end

  it "draws a card when it enters if you attacked this turn (raid)" do
    attack_with_a_creature!
    hand_size = p1.hand.count
    ResolvePermanent("Storm Fleet Spy", owner: p1)

    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "draws nothing when you did not attack this turn" do
    go_to_main_phase!
    hand_size = p1.hand.count
    ResolvePermanent("Storm Fleet Spy", owner: p1)

    expect(p1.hand.count).to eq(hand_size)
  end

  it "draws nothing when only the opponent attacked this turn" do
    go_to_main_phase_for!(p2)
    attacker = ResolvePermanent("Grizzly Bears", owner: p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker: attacker, target: p1)
    current_turn.attackers_declared!
    hand_size = p1.hand.count
    ResolvePermanent("Storm Fleet Spy", owner: p1)

    expect(p1.hand.count).to eq(hand_size)
  end
end
