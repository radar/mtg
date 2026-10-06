# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DestructiveTampering do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast(mode, *targets)
    card = Card("Destructive Tampering", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 3)
    p1.cast(card:) do |action|
      action.pay_mana(generic: { red: 2 }, red: 1)
      action.choose_mode(mode) { _1.targeting(*targets) if targets.any? }
    end
    game.stack.resolve!
    game.settle!
  end

  it "destroys target artifact" do
    ring = ResolvePermanent("Sol Ring", owner: p2)
    cast(described_class::DestroyArtifact, ring)

    expect(ring.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "makes creatures without flying unable to block this turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    angel = ResolvePermanent("Serra Angel", owner: p2)
    attacker = ResolvePermanent("Grizzly Bears", owner: p1)
    cast(described_class::CantBlock)

    expect(bears.can_block?(attacker)).to eq(false)
    expect(angel.can_block?(attacker)).to eq(true)
  end

  it "wears off at end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    attacker = ResolvePermanent("Grizzly Bears", owner: p1)
    cast(described_class::CantBlock)
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(bears.can_block?(attacker)).to eq(true)
  end
end
