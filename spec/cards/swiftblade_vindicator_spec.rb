# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SwiftbladeVindicator do
  include_context "two player game"

  let!(:vindicator) { ResolvePermanent("Swiftblade Vindicator", owner: p1) }

  it "is a 1/1 with double strike, vigilance and trample" do
    expect([vindicator.power, vindicator.toughness]).to eq([1, 1])
    expect(vindicator).to be_double_strike
    expect(vindicator).to be_vigilant
    expect(vindicator).to be_trample
  end

  it "deals damage twice to a player" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(vindicator, target: p2)
    current_turn.attackers_declared!
    current_turn.combat_damage!
    game.settle!

    expect(p2.life).to eq(18)
  end
end
