# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PeerPastTheVeil do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:peer) { Card("Peer Past The Veil") }

  def cast_peer!
    p1.hand.add(peer)
    p1.add_mana(red: 1, green: 1, colorless: 2)
    p1.cast(card: peer) { _1.pay_mana(generic: { colorless: 2 }, red: 1, green: 1) }
    game.stack.resolve!
    game.settle!
  end

  def set_hand!(*names)
    [*p1.hand.cards].each { p1.hand.remove(_1) }
    names.each { p1.hand.add(Card(_1, owner: p1)) }
  end

  it "discards your hand and draws a card for each card type in your graveyard" do
    set_hand!("Forest", "Grizzly Bears", "Lightning Bolt")
    cast_peer!

    expect(p1.graveyard.cards.map(&:name)).to include("Forest", "Grizzly Bears", "Lightning Bolt")
    expect(p1.hand.cards.count).to eq(3)
  end

  it "counts each card type only once" do
    set_hand!("Forest", "Forest", "Forest")
    cast_peer!

    expect(p1.hand.cards.count).to eq(1)
  end

  it "counts types already in the graveyard" do
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    set_hand!("Forest")
    cast_peer!

    expect(p1.hand.cards.count).to eq(2)
  end

  it "does not count itself" do
    set_hand!
    cast_peer!

    expect(p1.hand.cards.count).to eq(0)
    expect(p1.graveyard.cards.map(&:name)).to eq(["Peer Past The Veil"])
  end
end
