# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::JoltedAwake do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:spell) { Card("Jolted Awake", owner: p1).tap { p1.hand.add(_1) } }
  let(:bears) { Card("Grizzly Bears", owner: p1).tap { p1.graveyard.add(_1) } }
  let(:sol_ring) { Card("Sol Ring", owner: p1).tap { p1.graveyard.add(_1) } }
  let(:angel) { Card("Serra Angel", owner: p1).tap { p1.graveyard.add(_1) } }

  def cast!(*targets)
    p1.add_mana(white: 1)
    p1.cast(card: spell) { |a| a.pay_mana(white: 1).targeting(*targets) }
    game.stack.resolve!
    game.settle!
  end

  it "gives two energy with no target" do
    cast!

    expect(p1.energy).to eq(2)
    expect(game.choices).to be_empty
  end

  it "may pay energy equal to the creature's mana value to return it to the battlefield" do
    cast!(bears)

    expect(game.choices.first).to be_a(Magic::Choice::PayEnergy)
    game.resolve_choice!
    game.settle!

    expect(p1.energy).to eq(0)
    expect(bears.zone).to be_battlefield
    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
  end

  it "returns an artifact card too" do
    cast!(sol_ring)
    game.resolve_choice!
    game.settle!

    expect(p1.energy).to eq(1)
    expect(game.battlefield.permanents.map(&:name)).to include("Sol Ring")
  end

  it "keeps the card in the graveyard and the energy when you decline" do
    cast!(bears)
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(2)
    expect(bears.zone).to be_graveyard
  end

  it "offers no payment when the mana value is more than your energy" do
    cast!(angel)

    expect(game.choices).to be_empty
    expect(p1.energy).to eq(2)
    expect(angel.zone).to be_graveyard
  end

  it "counts energy you already had" do
    p1.add_counter("energy", amount: 3)
    cast!(angel)
    game.resolve_choice!
    game.settle!

    expect(p1.energy).to eq(0)
    expect(angel.zone).to be_battlefield
  end

  it "rejects a noncreature nonartifact card" do
    bolt = Card("Lightning Bolt", owner: p1).tap { p1.graveyard.add(_1) }

    expect { cast!(bolt) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "rejects a card in the opponent's graveyard" do
    theirs = Card("Grizzly Bears", owner: p2).tap { p2.graveyard.add(_1) }

    expect { cast!(theirs) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "rejects two targets" do
    expect { cast!(bears, sol_ring) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end

  it "does nothing to a card that left the graveyard in response" do
    p1.add_mana(white: 1)
    p1.cast(card: spell) { |a| a.pay_mana(white: 1).targeting(bears) }
    bears.exile!
    game.stack.resolve!
    game.settle!

    expect(bears.zone).to be_exile
    expect(game.choices).to be_empty
  end

  context "cycling {2}" do
    it "discards the card and draws a card" do
      p1.add_mana(white: 2)
      top = p1.library.first

      p1.cycle(card: spell) { |a| a.pay_mana(generic: { white: 2 }) }

      expect(spell.zone).to be_graveyard
      expect(p1.hand).to include(top)
    end
  end
end
