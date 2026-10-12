# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Shroudstomper do
  include_context "two player game"

  def drain_applied?(life_before)
    p2.life == life_before[:p2] - 2 && p1.life == life_before[:p1] + 2
  end

  it "is a 5/5 deathtouch Elemental" do
    stomper = ResolvePermanent("Shroudstomper", owner: p1)

    expect([stomper.power, stomper.toughness]).to eq([5, 5])
    expect(stomper).to be_deathtouch
  end

  it "drains 2 and draws a card when it enters" do
    before = { p1: p1.life, p2: p2.life }
    hand = p1.hand.count
    ResolvePermanent("Shroudstomper", owner: p1)
    game.stack.resolve!
    game.settle!

    expect(drain_applied?(before)).to be(true)
    expect(p1.hand.count).to eq(hand + 1)
  end

  it "drains 2 and draws a card when it attacks" do
    stomper = ResolvePermanent("Shroudstomper", owner: p1)
    game.stack.resolve!
    game.settle!
    before = { p1: p1.life, p2: p2.life }
    hand = p1.hand.count
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(stomper, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.stack.resolve!
    game.settle!

    expect(drain_applied?(before)).to be(true)
    expect(p1.hand.count).to be > hand
  end
end
