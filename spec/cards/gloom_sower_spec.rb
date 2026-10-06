# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GloomSower do
  include_context "two player game"

  let!(:sower) { ResolvePermanent("Gloom Sower", owner: p1) }

  it "is an 8/6 Horror" do
    expect([sower.power, sower.toughness]).to eq([8, 6])
  end

  it "drains 2 from the blocker's controller each time it is blocked" do
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: sower, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: sower)
    game.settle!

    expect(p2.life).to eq(18)
    expect(p1.life).to eq(22)
  end

  it "doesn't trigger when another creature is blocked" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    blocker = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bears, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(blocker, attacker: bears)
    game.settle!

    expect(p2.life).to eq(20)
  end
end
