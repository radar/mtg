# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AmpedRaptor do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:raptor) { Card("Amped Raptor", owner: p1).tap { p1.hand.add(_1) } }

  # Puts the cards on top of p1's library, first one on top.
  def stack_library(*names)
    names.reverse.map { |name| Card(name, owner: p1).tap { p1.library.add(_1) } }.reverse
  end

  def cast_raptor!
    p1.add_mana(red: 2)
    p1.cast(card: raptor) { |a| a.pay_mana(generic: { red: 1 }, red: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/1 Dinosaur with first strike" do
    permanent = ResolvePermanent("Amped Raptor", owner: p1)
    expect([permanent.power, permanent.toughness]).to eq([2, 1])
    expect(permanent).to be_first_strike
    expect(permanent.type?("Dinosaur")).to be(true)
  end

  it "gives two energy when it enters" do
    stack_library("Mountain")
    cast_raptor!

    expect(p1.energy).to eq(2)
  end

  context "cast from your hand" do
    it "exiles until a nonland card, then lets you pay its mana value in energy to cast it" do
      land, bears = stack_library("Mountain", "Grizzly Bears", "Island")
      cast_raptor!

      expect(land.zone).to be_exile
      expect(bears.zone).to be_exile
      expect(game.choices.first).to be_a(Magic::Choice::PayEnergy)
      game.resolve_choice!
      game.stack.resolve!
      game.settle!

      expect(p1.energy).to eq(0)
      expect(bears.zone).to be_battlefield
    end

    it "leaves the card exiled when you decline" do
      _, bears = stack_library("Mountain", "Grizzly Bears")
      cast_raptor!
      game.skip_choice!
      game.settle!

      expect(p1.energy).to eq(2)
      expect(bears.zone).to be_exile
    end

    it "offers nothing when the mana value is more than your energy" do
      _, angel = stack_library("Mountain", "Serra Angel")
      cast_raptor!

      expect(game.choices).to be_empty
      expect(angel.zone).to be_exile
    end

    it "casts a targeted spell at a chosen target" do
      stack_library("Lightning Bolt")
      enemy = ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Serra Angel", owner: p2)
      cast_raptor!
      game.resolve_choice!
      expect(game.choices.first).to be_a(Magic::Choice::Targeted)
      game.resolve_choice!(target: enemy)
      game.stack.resolve!
      game.settle!

      expect(p1.energy).to eq(1)
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "casts at the first target when the target step is skipped" do
      stack_library("Lightning Bolt")
      enemy = ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Serra Angel", owner: p2)
      cast_raptor!
      game.resolve_choice!
      first = game.choices.first.choices.first
      game.skip_choice!
      game.stack.resolve!
      game.settle!

      expect(p1.energy).to eq(1)
      expect(first).to eq(enemy).or eq(p2.creatures.find { _1.name == "Serra Angel" })
      hit = first == enemy ? p2.graveyard.cards.map(&:name).include?("Grizzly Bears") : first.damage == 3
      expect(hit).to be(true)
    end

    it "does nothing when the library has only lands" do
      cast_raptor!

      expect(p1.library).to be_empty
      expect(game.choices).to be_empty
    end
  end

  context "not cast from your hand" do
    it "gives energy but exiles nothing" do
      top, = stack_library("Grizzly Bears")
      ResolvePermanent("Amped Raptor", owner: p1)

      expect(p1.energy).to eq(2)
      expect(top.zone).to be_library
      expect(game.choices).to be_empty
    end
  end
end
