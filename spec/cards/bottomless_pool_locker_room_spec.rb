# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BottomlessPoolLockerRoom do
  include_context "two player game"

  before { go_to_main_phase! }

  context "Bottomless Pool" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

    def unlock_pool
      room = ResolvePermanent("Bottomless Pool Locker Room", doors: [:right])
      p1.add_mana(blue: 1)
      p1.unlock_door(permanent: room, door: :left) { |a| a.pay_mana(blue: 1) }
      game.settle!
    end

    it "returns up to one target creature to its owner's hand when unlocked" do
      unlock_pool
      game.resolve_choice!(target: bears)

      expect(bears.zone).to be_nil
      expect(p2.hand.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "may return no creature" do
      unlock_pool
      game.skip_choice!

      expect(bears.zone).to be_battlefield
      expect(mine.zone).to be_battlefield
    end

    it "triggers when the Room is cast as Bottomless Pool" do
      card = Card("Bottomless Pool Locker Room", owner: p1)
      p1.hand.add(card)
      p1.add_mana(blue: 1)
      p1.cast(card: card, door: :left) { |a| a.pay_mana(blue: 1) }
      game.stack.resolve!
      game.settle!

      expect(game.choices.first).to be_a(described_class::BottomlessPool::BounceChoice)
    end
  end

  context "Locker Room" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:room) { ResolvePermanent("Bottomless Pool Locker Room", doors: [:right]) }

    def combat_damage(source, to: p2)
      game.notify!(Magic::Events::DamageDealt.new(source: source, target: to, damage: 2, combat: true))
      game.settle!
    end

    it "draws a card when a creature you control deals combat damage to a player" do
      hand_size = p1.hand.cards.count
      combat_damage(bears)

      expect(p1.hand.cards.count).to eq(hand_size + 1)
    end

    it "draws only one card when several creatures deal damage in the same step" do
      other = ResolvePermanent("Grizzly Bears", owner: p1)
      hand_size = p1.hand.cards.count
      combat_damage(bears)
      combat_damage(other)

      expect(p1.hand.cards.count).to eq(hand_size + 1)
    end

    it "ignores opposing creatures, damage to creatures and noncombat damage" do
      hand_size = p1.hand.cards.count
      combat_damage(theirs, to: p1)
      game.notify!(Magic::Events::DamageDealt.new(source: bears, target: theirs, damage: 2, combat: true))
      game.notify!(Magic::Events::DamageDealt.new(source: bears, target: p2, damage: 2, combat: false))
      game.settle!

      expect(p1.hand.cards.count).to eq(hand_size)
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:right)
      hand_size = p1.hand.cards.count
      combat_damage(bears)

      expect(p1.hand.cards.count).to eq(hand_size)
    end
  end
end
