# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MeatLockerDrownedDiner do
  include_context "two player game"

  before { go_to_main_phase! }

  context "Meat Locker" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

    def unlock_meat_locker
      room = ResolvePermanent("Meat Locker Drowned Diner", doors: [:right])
      p1.add_mana(blue: 3)
      p1.unlock_door(permanent: room, door: :left) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }
      game.settle!
    end

    it "taps up to one target creature and puts two stun counters on it" do
      unlock_meat_locker
      game.resolve_choice!(target: bears)

      expect(bears).to be_tapped
      expect(bears.counters.of_type(Magic::Counters::Stun).count).to eq(2)
    end

    it "may target no creature" do
      unlock_meat_locker
      game.skip_choice!

      expect(bears).not_to be_tapped
      expect(mine).not_to be_tapped
    end
  end

  context "Drowned Diner" do
    it "draws three cards, then discards a card when unlocked" do
      room = ResolvePermanent("Meat Locker Drowned Diner", doors: [:left])
      p1.add_mana(blue: 5)
      hand_size = p1.hand.cards.count
      p1.unlock_door(permanent: room, door: :right) { |a| a.pay_mana(generic: { blue: 3 }, blue: 2) }
      game.settle!

      expect(game.choices.first).to be_a(Magic::Choice::Discard)
      game.resolve_choice!(card: p1.hand.cards.first)

      expect(p1.hand.cards.count).to eq(hand_size + 2)
      expect(p1.graveyard.cards.count).to eq(1)
    end
  end
end
