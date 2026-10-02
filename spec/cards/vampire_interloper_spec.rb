# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VampireInterloper do
  include_context "two player game"

  let!(:interloper) { ResolvePermanent("Vampire Interloper", owner: p1) }

  it "is a 2/1 flying Vampire Scout" do
    expect([interloper.power, interloper.toughness]).to eq([2, 1])
    expect(interloper).to be_flying
  end

  it "can't block" do
    attacker = ResolvePermanent("Healer's Hawk", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(attacker, target: p1)
    current_turn.attackers_declared!

    expect { current_turn.declare_blocker(interloper, attacker:) }.to raise_error(Magic::Game::CombatPhase::IllegalBlock)
  end
end
