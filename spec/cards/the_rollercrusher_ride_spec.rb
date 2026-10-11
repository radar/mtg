# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheRollercrusherRide do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("The Rollercrusher Ride", owner: p1).tap { p1.hand.add(_1) } }

  def cast(x:)
    p1.add_mana(red: 3 + x)
    p1.cast(card: card, value_for_x: x) { _1.pay_mana(generic: { red: 2 }, red: 1, x: { red: x }) }
    game.stack.resolve!
    game.settle!
  end

  def delirium! = %w[Forest Lightning\ Bolt Sol\ Ring].each { p1.graveyard.add(Card(_1, owner: p1)) }

  describe "when it enters" do
    let!(:ogre) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:other) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "deals X damage to each of up to X target creatures" do
      cast(x: 2)
      game.resolve_choice!(targets: [ogre, other])
      game.settle!

      expect([ogre.zone, other.zone]).to all(be_nil)
      expect(mine.zone).to be_battlefield
    end

    it "may target fewer than X" do
      cast(x: 2)
      game.resolve_choice!(targets: [ogre])
      game.settle!

      expect(ogre.zone).to be_nil
      expect(other.zone).to be_battlefield
    end

    it "can't target more than X" do
      cast(x: 1)

      expect { game.resolve_choice!(targets: [ogre, other]) }.to raise_error(StandardError)
    end

    it "does nothing for X = 0" do
      cast(x: 0)

      expect(game.choices).to be_empty
    end
  end

  describe "delirium" do
    let!(:ride) { ResolvePermanent("The Rollercrusher Ride", owner: p1, value_for_x: 0) }

    def bolt!(target)
      spell = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
      p1.add_mana(red: 1)
      p1.cast(card: spell) { _1.pay_mana(red: 1).targeting(target) }
      game.stack.resolve!
      game.settle!
    end

    it "doubles noncombat damage you deal with four card types in your graveyard" do
      delirium!
      p1.graveyard.add(Card("Grizzly Bears", owner: p1))
      bolt!(p2)

      expect(p2.life).to eq(14)
    end

    it "does nothing without delirium" do
      bolt!(p2)

      expect(p2.life).to eq(17)
    end

    it "doesn't double damage an opponent's source deals" do
      delirium!
      p1.graveyard.add(Card("Grizzly Bears", owner: p1))
      game.next_turn
      go_to_main_phase!
      spell = Card("Lightning Bolt", owner: p2).tap { p2.hand.add(_1) }
      p2.add_mana(red: 1)
      p2.cast(card: spell) { _1.pay_mana(red: 1).targeting(p1) }
      game.stack.resolve!
      game.settle!

      expect(p1.life).to eq(17)
    end
  end
end
