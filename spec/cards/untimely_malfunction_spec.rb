# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UntimelyMalfunction do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast(mode, *targets)
    card = Card("Untimely Malfunction", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 2)
    p1.cast(card:) do |action|
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.choose_mode(mode) { _1.targeting(*targets) if targets.any? }
    end
  end

  it "destroys target artifact" do
    ring = ResolvePermanent("Sol Ring", owner: p2)
    cast(described_class::DestroyArtifact, ring)
    game.stack.resolve!
    game.settle!

    expect(ring.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "changes the target of a spell with a single target" do
    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)
    p2.cast(card: bolt) { |a| a.pay_mana(red: 1); a.targeting(p1) }
    spell = game.stack.spells.first

    cast(described_class::ChangeTarget, spell)
    game.stack.resolve!
    game.resolve_choice!(target: p2)
    game.stack.resolve!

    expect(p2.life).to eq(17)
    expect(p1.life).to eq(20)
  end

  it "makes one or two target creatures unable to block this turn" do
    a = ResolvePermanent("Grizzly Bears", owner: p2)
    b = ResolvePermanent("Grizzly Bears", owner: p2)
    c = ResolvePermanent("Grizzly Bears", owner: p2)
    attacker = ResolvePermanent("Grizzly Bears", owner: p1)
    cast(described_class::CantBlock, a, b)
    game.stack.resolve!
    game.settle!

    expect(a.can_block?(attacker)).to eq(false)
    expect(b.can_block?(attacker)).to eq(false)
    expect(c.can_block?(attacker)).to eq(true)
  end
end
