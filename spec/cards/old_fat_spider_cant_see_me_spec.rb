# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OldFatSpiderCantSeeMe do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Ordinary Bear", owner: p1) }
  let(:saga) { Card("Old Fat Spider Cant See Me", owner: p1) }

  def cast_saga
    p1.hand.add(saga)
    go_to_main_phase!
    p1.add_mana(blue: 3)
    p1.cast(card: saga) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  def next_chapter
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  def saga_permanent = p1.permanents.find { _1.name == "Old Fat Spider Can't See Me" }

  def bolt(target)
    p2.add_mana(red: 1)
    action = cast_action(card: Card("Lightning Bolt", owner: p2), player: p2)
    action.pay_mana(red: 1)
    action.targeting(target)
    game.take_action(action)
  end

  context "chapter I" do
    before do
      cast_saga
      game.resolve_choice!(target: bear)
      game.tick!
    end

    it "gives the chosen creature hexproof" do
      expect(bear).to have_keyword(:hexproof)
      expect(other).not_to have_keyword(:hexproof)
    end

    it "stops opponents targeting it" do
      expect { bolt(bear) }.to raise_error(StandardError)
    end

    it "ends when the Saga leaves the battlefield" do
      saga_permanent.sacrifice!
      game.settle!
      game.tick!

      expect(bear).not_to have_keyword(:hexproof)
    end
  end

  context "chapter II" do
    before do
      cast_saga
      game.resolve_choice!(target: bear)
    end

    def attack_with(*creatures)
      skip_to_combat!
      current_turn.declare_attackers!
      creatures.each { current_turn.declare_attacker(_1, target: p2) }
      current_turn.attackers_declared!
      current_turn.combat_damage!
      game.settle!
    end

    it "prevents all damage dealt by the chosen creature" do
      next_chapter
      game.resolve_choice!(target: bear)
      attack_with(bear)

      expect(p2.life).to eq(20)
    end

    it "doesn't prevent damage from other creatures" do
      next_chapter
      game.resolve_choice!(target: bear)
      attack_with(other)

      expect(p2.life).to eq(16)
    end

    it "can be declined (up to one target)" do
      next_chapter
      game.skip_choice!
      attack_with(bear)

      expect(p2.life).to eq(18)
    end
  end

  context "chapters III and IV" do
    it "draw a card each" do
      cast_saga
      game.resolve_choice!(target: bear)
      next_chapter
      game.skip_choice!
      hand = p1.hand.count
      next_chapter
      expect(p1.hand.count).to eq(hand + 2) # draw step + chapter III
      next_chapter
      expect(p1.hand.count).to eq(hand + 4)
    end
  end
end
