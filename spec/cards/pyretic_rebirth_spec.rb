# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PyreticRebirth do
  include_context "two player game"

  let(:spell) { Card("Pyretic Rebirth", owner: p1).tap { p1.hand.add(_1) } }
  let(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }
  let(:sol_ring) { Card("Sol Ring", owner: p1).tap { p1.graveyard.add(_1) } }

  def cast!(*targets, player: p1)
    player.add_mana(black: 2, red: 2)
    player.cast(card: spell) { |a| a.pay_mana(generic: { black: 1, red: 1 }, black: 1, red: 1).targeting(*targets) }
    game.stack.resolve!
    game.settle!
  end

  it "returns a creature card to hand and deals damage equal to its mana value" do
    victim = ResolvePermanent("Serra Angel", owner: p2)
    cast!(bears, victim)

    expect(bears.zone).to be_hand
    expect(victim.damage).to eq(2)
  end

  it "kills a creature when the mana value is enough" do
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    cast!(bears, victim)

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "returns an artifact card, dealing damage equal to its mana value" do
    victim = ResolvePermanent("Serra Angel", owner: p2)
    cast!(sol_ring, victim)

    expect(sol_ring.zone).to be_hand
    expect(victim.damage).to eq(1)
  end

  it "can target a planeswalker" do
    walker = ResolvePermanent("Ajani Outland Chaperone", owner: p2)
    before = walker.loyalty
    cast!(bears, walker)

    expect(walker.loyalty).to eq(before - 2)
  end

  it "may target no creature or planeswalker" do
    cast!(bears)

    expect(bears.zone).to be_hand
  end

  it "uses the returned card's mana value, not a fixed amount" do
    angel = Card("Serra Angel", owner: p1).tap { p1.graveyard.add(_1) }
    victim = ResolvePermanent("Shivan Dragon", owner: p2)
    cast!(angel, victim)

    expect(angel.zone).to be_hand
    expect(p2.graveyard.cards.map(&:name)).to include("Shivan Dragon")
  end

  it "rejects a non-artifact non-creature card" do
    bolt = Card("Lightning Bolt", owner: p1).tap { p1.graveyard.add(_1) }

    expect { cast!(bolt) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "rejects a card in the opponent's graveyard" do
    theirs = Card("Grizzly Bears", owner: p2).tap { p2.graveyard.add(_1) }

    expect { cast!(theirs) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "can't target a hexproof creature with the damage" do
    big = ResolvePermanent("Gigantic Big Bear", owner: p2)

    expect { cast!(bears, big) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "does not return the card or deal damage if the card left the graveyard in response" do
    victim = ResolvePermanent("Serra Angel", owner: p2)
    p1.add_mana(black: 2, red: 2)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { black: 1, red: 1 }, black: 1, red: 1).targeting(bears, victim) }
    bears.exile!
    game.stack.resolve!
    game.settle!

    expect(bears.zone).to be_exile
    expect(victim.damage).to eq(0)
  end
end
