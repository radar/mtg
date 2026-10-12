# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EntityTracker do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:tracker) { ResolvePermanent("Entity Tracker", owner: p1) }

  it "is a 2/3 Human Scout with flash" do
    expect([tracker.power, tracker.toughness]).to eq([2, 3])
    expect(tracker.type?("Scout")).to be(true)
    expect(tracker).to have_keyword(:flash)
  end

  it "draws a card whenever an enchantment you control enters" do
    expect { eerie_enchantment_enters! }.to change { p1.hand.cards.count }.by(1)
  end

  it "draws a card whenever you fully unlock a Room" do
    room = eerie_room
    expect { eerie_fully_unlock_room!(room) }.to change { p1.hand.cards.count }.by(1)
  end

  it "does not draw when an enchantment enters under your opponent's control" do
    expect { ResolvePermanent("Sanctum Of Calm Waters", owner: p2) }.not_to(change { p1.hand.cards.count })
  end

  it "does not draw when a nonenchantment permanent enters" do
    expect { ResolvePermanent("Grizzly Bears", owner: p1) }.not_to(change { p1.hand.cards.count })
  end

  it "draws once, not twice, when a Room is cast: it enters as an enchantment but is not fully unlocked" do
    card = Card("Funeral Room Awakening Hall", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)

    # -1 for the Room leaving the hand, +1 for the card drawn as it enters
    expect do
      p1.cast(card: card, door: :left) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
      game.stack.resolve!
      game.settle!
    end.not_to(change { p1.hand.cards.count })
  end
end
