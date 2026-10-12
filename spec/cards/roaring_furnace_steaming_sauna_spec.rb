# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RoaringFurnaceSteamingSauna do
  include_context "two player game"

  before { go_to_main_phase! }

  def unlock(room, side, mana)
    p1.add_mana(**mana)
    p1.unlock_door(permanent: room, door: side) { _1.auto_pay }
    game.settle!
  end

  describe "Roaring Furnace" do
    it "deals damage equal to the cards in your hand to target creature an opponent controls" do
      big = ResolvePermanent("Baneslayer Angel", owner: p2)
      ResolvePermanent("Grizzly Bears", owner: p1)
      room = ResolvePermanent("Roaring Furnace Steaming Sauna", doors: [:right])
      hand = p1.hand.cards.count
      unlock(room, :left, red: 2)

      expect(big.damage).to eq(hand)
    end

    it "only targets creatures your opponents control" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      theirs_too = ResolvePermanent("Grizzly Bears", owner: p2)
      room = ResolvePermanent("Roaring Furnace Steaming Sauna", doors: [:right])
      unlock(room, :left, red: 2)

      expect(game.choices.last.choices).to contain_exactly(theirs, theirs_too)
      expect(game.choices.last.choices).not_to include(mine)
    end
  end

  describe "Steaming Sauna" do
    let!(:room) { ResolvePermanent("Roaring Furnace Steaming Sauna", doors: [:right]) }

    it "draws a card at the beginning of your end step" do
      hand = p1.hand.cards.count
      current_turn.end!
      game.settle!

      expect(p1.hand.cards.count).to eq(hand + 1)
    end

    it "gives you no maximum hand size" do
      5.times { p1.hand.add(Card("Forest", owner: p1)) }
      current_turn.end!
      current_turn.cleanup!

      expect(p1.hand.cards.count).to be > 7
      expect(game.choices).to be_empty
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:right)
      hand = p1.hand.cards.count
      current_turn.end!
      game.settle!

      expect(p1.hand.cards.count).to eq(hand)
    end
  end
end
