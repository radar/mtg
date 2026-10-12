# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DerelictAtticWidowsWalk do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  context "Derelict Attic" do
    it "draws two cards and loses 2 life when it is unlocked" do
      go_to_main_phase!
      room = ResolvePermanent("Derelict Attic Widows Walk", doors: [:right])
      p1.add_mana(black: 3)
      hand_size = p1.hand.cards.count
      p1.unlock_door(permanent: room, door: :left) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
      game.settle!

      expect(p1.hand.cards.count).to eq(hand_size + 2)
      expect(p1.life).to eq(18)
    end

    it "does the same when the Room is cast as Derelict Attic" do
      go_to_main_phase!
      card = Card("Derelict Attic Widows Walk", owner: p1)
      p1.hand.add(card)
      p1.add_mana(black: 3)
      hand_size = p1.hand.cards.count
      p1.cast(card: card, door: :left) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
      game.stack.resolve!
      game.settle!

      expect(p1.hand.cards.count).to eq(hand_size - 1 + 2)
      expect(p1.life).to eq(18)
    end
  end

  context "Widow's Walk" do
    let!(:other_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:room) { ResolvePermanent("Derelict Attic Widows Walk", doors: [:right]) }

    def attack_with(*attackers)
      skip_to_combat!
      current_turn.declare_attackers!
      attackers.each { p1.declare_attacker(attacker: _1, target: p2) }
      current_turn.attackers_declared!
      game.tick!
    end

    it "gives a creature attacking alone +1/+0 and deathtouch until end of turn" do
      attack_with(bears)

      expect([bears.power, bears.toughness]).to eq([3, 2])
      expect(bears.has_keyword?(Magic::Cards::Keywords::DEATHTOUCH)).to eq(true)
    end

    it "does nothing when more than one creature attacks" do
      attack_with(bears, other_bears)

      expect(bears.power).to eq(2)
      expect(bears.has_keyword?(Magic::Cards::Keywords::DEATHTOUCH)).to eq(false)
    end

    it "does nothing while the door is locked" do
      room.lock_door!(:right)
      attack_with(bears)

      expect(bears.power).to eq(2)
    end
  end
end
