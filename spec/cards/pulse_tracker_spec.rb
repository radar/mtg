# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PulseTracker do
  include_context "two player game"

  let!(:tracker) { ResolvePermanent("Pulse Tracker", owner: p1) }

  def attack_with(creature)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(creature, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 1/1 Vampire Rogue" do
    expect([tracker.power, tracker.toughness]).to eq([1, 1])
  end

  it "makes each opponent lose 1 life when it attacks" do
    attack_with(tracker)

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end

  it "doesn't trigger when another creature attacks" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    attack_with(bears)

    expect(p2.life).to eq(20)
  end
end
