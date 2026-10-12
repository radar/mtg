# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WalkInClosetForgottenCellar do
  include_context "two player game"

  before { go_to_main_phase! }

  describe "Walk-In Closet" do
    let!(:room) { ResolvePermanent("Walk In Closet Forgotten Cellar", doors: [:left]) }
    let!(:forest) { Card("Forest", owner: p1).tap { p1.graveyard.add(_1) } }

    it "lets you play lands from your graveyard" do
      p1.play_land(land: forest)

      expect(p1.lands.map(&:card)).to include(forest)
    end

    it "doesn't let you cast nonland cards from your graveyard" do
      bolt = Card("Lightning Bolt", owner: p1).tap { p1.graveyard.add(_1) }
      p1.add_mana(red: 1)

      expect(Magic::Actions::Cast.new(game: game, player: p1, card: bolt)).not_to be_legal
    end

    it "doesn't let you play a land from your opponent's graveyard" do
      theirs = Card("Forest", owner: p2).tap { p2.graveyard.add(_1) }

      expect(Magic::Actions::PlayLand.new(game: game, player: p1, card: theirs)).not_to be_legal
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:left)

      expect(Magic::Actions::PlayLand.new(game: game, player: p1, card: forest)).not_to be_legal
    end
  end

  describe "Forgotten Cellar" do
    let!(:room) { ResolvePermanent("Walk In Closet Forgotten Cellar", doors: [:left]) }
    let!(:bolt) { Card("Lightning Bolt", owner: p1).tap { p1.graveyard.add(_1) } }

    def unlock!
      p1.add_mana(green: 5)
      p1.unlock_door(permanent: room, door: :right) { _1.auto_pay }
      game.settle!
    end

    it "lets you cast spells from your graveyard this turn" do
      unlock!
      p1.add_mana(red: 1)
      p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p2) }
      game.stack.resolve!

      expect(p2.life).to eq(17)
    end

    it "exiles a card that would be put into your graveyard this turn instead" do
      unlock!
      discarded = Card("Forest", owner: p1).tap { p1.hand.add(_1) }
      discarded.discard!
      game.settle!

      expect(discarded.zone).to be_exile
    end

    it "exiles the spell after it resolves from the graveyard" do
      unlock!
      p1.add_mana(red: 1)
      p1.cast(card: bolt) { _1.pay_mana(red: 1).targeting(p2) }
      game.stack.resolve!

      expect(bolt.zone).to be_exile
    end

    it "stops at the end of the turn" do
      unlock!
      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!
      game.next_turn
      game.next_turn
      go_to_main_phase!
      later = Card("Forest", owner: p1).tap { p1.hand.add(_1) }
      later.discard!
      game.settle!

      expect(later.zone).to be_graveyard
    end

    it "leaves your opponent's cards alone" do
      unlock!
      theirs = Card("Forest", owner: p2).tap { p2.hand.add(_1) }
      theirs.discard!
      game.settle!

      expect(theirs.zone).to be_graveyard
    end
  end
end
