# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GhostlyDancers do
  include_context "two player game"

  before { go_to_main_phase! }

  def spirits = p1.creatures.select { _1.type?("Spirit") && _1.power == 3 }

  def enter!
    ResolvePermanent("Ghostly Dancers", owner: p1)
    game.settle!
  end

  it "is a 2/5 flying Spirit" do
    dancers = ResolvePermanent("Ghostly Dancers", owner: p1)

    expect([dancers.power, dancers.toughness]).to eq([2, 5])
    expect(dancers).to have_keyword(:flying)
  end

  describe "when it enters" do
    let!(:room) { ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: [:left]) }
    let!(:enchantment) do
      Card("Sanctum Of Calm Waters", owner: p1).tap { p1.graveyard.add(_1) }
    end

    it "offers both modes when both are possible" do
      enter!

      expect(game.choices.last.choices).to contain_exactly(:return, :unlock)
    end

    it "returns an enchantment card from your graveyard to your hand" do
      enter!
      game.resolve_choice!(mode: :return)
      game.resolve_choice!(target: enchantment)

      expect(p1.hand.cards).to include(enchantment)
      expect(p1.graveyard.cards).not_to include(enchantment)
    end

    it "unlocks a locked door of a Room you control" do
      enter!
      game.resolve_choice!(mode: :unlock)

      expect(room.card).to be_fully_unlocked
    end

    it "offers only the unlock when there is no enchantment card in the graveyard" do
      p1.graveyard.remove(enchantment)
      enter!

      expect(game.choices.last.choices).to eq([:unlock])
    end

    it "offers only the return when every Room is fully unlocked" do
      room.card.unlock!(:right)
      enter!

      expect(game.choices.last.choices).to eq([:return])
    end

    it "does nothing when neither mode is possible" do
      p1.graveyard.remove(enchantment)
      room.card.unlock!(:right)
      enter!

      expect(game.choices).to be_empty
    end
  end

  describe "Eerie" do
    let!(:dancers) { ResolvePermanent("Ghostly Dancers", owner: p1) }

    it "creates a 3/1 white flying Spirit whenever an enchantment you control enters" do
      eerie_enchantment_enters!

      expect(spirits.size).to eq(1)
      expect([spirits.first.power, spirits.first.toughness]).to eq([3, 1])
      expect(spirits.first.colors).to eq([:white])
      expect(spirits.first).to have_keyword(:flying)
    end

    it "creates another whenever you fully unlock a Room" do
      room = eerie_room
      expect(spirits.size).to eq(1)

      eerie_fully_unlock_room!(room)
      expect(spirits.size).to eq(2)
    end

    it "does nothing when an enchantment enters under your opponent's control" do
      ResolvePermanent("Sanctum Of Calm Waters", owner: p2)

      expect(spirits).to be_empty
    end
  end
end
