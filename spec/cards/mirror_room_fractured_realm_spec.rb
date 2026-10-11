# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MirrorRoomFracturedRealm do
  include_context "two player game"

  before { go_to_main_phase! }

  describe "Mirror Room" do
    let!(:angel) { ResolvePermanent("Baneslayer Angel", owner: p1) }
    let!(:room) { ResolvePermanent("Mirror Room Fractured Realm", doors: [:right]) }

    def unlock!
      p1.add_mana(blue: 3)
      p1.unlock_door(permanent: room, door: :left) { _1.auto_pay }
      game.settle!
    end

    it "creates a token copy of target creature you control that is also a Reflection" do
      unlock!

      copy = p1.creatures.find { _1.token? && _1.name == "Baneslayer Angel" }
      expect(copy).not_to be_nil
      expect(copy.type?("Reflection")).to be(true)
      expect(copy.type?("Angel")).to be(true)
      expect(copy).to have_keyword(:flying)
    end

    it "doesn't make the original a Reflection" do
      unlock!

      expect(angel.type?("Reflection")).to be(false)
    end

    it "offers only creatures you control" do
      ResolvePermanent("Grizzly Bears", owner: p2)
      ResolvePermanent("Grizzly Bears", owner: p1)
      unlock!

      expect(game.choices.last.choices).to all(satisfy { _1.controller == p1 })
    end
  end

  describe "Fractured Realm" do
    let!(:room) { ResolvePermanent("Mirror Room Fractured Realm", doors: [:right]) }

    it "makes a triggered ability of a permanent you control trigger an additional time" do
      hand = p1.hand.cards.count
      ResolvePermanent("Entity Tracker", owner: p1)
      game.settle!
      eerie = ResolvePermanent("Sanctum Of Calm Waters", owner: p1)
      game.settle!
      game.skip_choice! while game.choices.any?

      # Entity Tracker draws on each Eerie trigger: Sanctum entering triggers it twice.
      expect(p1.hand.cards.count).to eq(hand + 2)
      expect(eerie).to be_enchantment
    end

    it "doesn't double an opponent's triggers" do
      ResolvePermanent("Entity Tracker", owner: p2)
      hand = p2.hand.cards.count
      ResolvePermanent("Sanctum Of Calm Waters", owner: p2)
      game.settle!
      game.skip_choice! while game.choices.any?

      expect(p2.hand.cards.count).to eq(hand + 1) # once, not twice
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:right)
      hand = p1.hand.cards.count
      ResolvePermanent("Entity Tracker", owner: p1)
      ResolvePermanent("Sanctum Of Calm Waters", owner: p1)
      game.settle!
      game.skip_choice! while game.choices.any?

      expect(p1.hand.cards.count).to eq(hand + 1)
    end
  end
end
