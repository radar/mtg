# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfInfinity do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:fear) { Card("Fear Of Infinity", owner: p1) }

  it "is a 2/2 flying, lifelink enchantment creature that can't block" do
    permanent = ResolvePermanent("Fear Of Infinity", owner: p1)

    expect([permanent.power, permanent.toughness]).to eq([2, 2])
    expect(permanent).to have_keyword(:flying)
    expect(permanent).to have_keyword(:lifelink)
    expect(permanent.card).to be_enchantment
    expect(permanent.can_block?(ResolvePermanent("Grizzly Bears", owner: p2))).to be(false)
  end

  context "in your graveyard" do
    before { p1.graveyard.add(fear) }

    it "may return to your hand whenever an enchantment you control enters" do
      eerie_enchantment_enters!
      game.resolve_choice!

      expect(p1.hand.cards).to include(fear)
      expect(p1.graveyard.cards).not_to include(fear)
    end

    it "may return to your hand whenever you fully unlock a Room" do
      room = eerie_room
      game.skip_choice!

      eerie_fully_unlock_room!(room)
      game.resolve_choice!

      expect(p1.hand.cards).to include(fear)
    end

    it "stays in the graveyard when you decline" do
      eerie_enchantment_enters!
      game.skip_choice!

      expect(p1.graveyard.cards).to include(fear)
    end

    it "does nothing when an enchantment enters under your opponent's control" do
      ResolvePermanent("Sanctum Of Calm Waters", owner: p2)
      game.settle!

      expect(game.choices).to be_empty
    end
  end

  context "on the battlefield or in your hand" do
    it "does not trigger from the battlefield" do
      ResolvePermanent("Fear Of Infinity", owner: p1)
      eerie_enchantment_enters!

      expect(game.choices).to be_empty
    end

    it "does not trigger from your hand" do
      p1.hand.add(fear)
      eerie_enchantment_enters!

      expect(game.choices).to be_empty
    end
  end
end
