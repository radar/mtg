# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MagnigothSentry do
  include_context "two player game"

  let!(:sentry) { ResolvePermanent("Magnigoth Sentry", owner: p1) }

  it "is a 4/4 Treefolk with reach" do
    expect([sentry.power, sentry.toughness]).to eq([4, 4])
    expect(sentry).to be_reach
  end

  it "can block a creature with flying" do
    flyer = ResolvePermanent("Healer's Hawk", owner: p2)
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(flyer, target: p1)
    current_turn.attackers_declared!

    expect { current_turn.declare_blocker(sentry, attacker: flyer) }.not_to raise_error
  end
end
