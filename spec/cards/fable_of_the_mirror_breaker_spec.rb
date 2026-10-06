# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FableOfTheMirrorBreaker do
  include_context "two player game"

  let!(:saga) { ResolvePermanent("Fable Of The Mirror-Breaker", owner: p1) }

  context "chapter 1" do
    it "creates a Goblin Shaman that makes a Treasure when it attacks" do
      go_to_main_phase!
      game.stack.resolve!
      game.tick!
      token = game.battlefield.by_name("Goblin Shaman").first
      expect(token).not_to be_nil
      token.grant_haste!
      game.tick!
      game.skip_choice! # chapter 2 fires at the same first main phase

      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(token, target: p2)
      current_turn.attackers_declared!
      game.settle!

      expect(p1.permanents.select { _1.name == "Treasure" }.count).to eq(1)
    end
  end

  context "chapter 3" do
    def reach_chapter_3
      saga.add_counter("lore", amount: 1)
      game.settle!
      game.skip_choice! if game.choices.any?
      saga.add_counter("lore", amount: 1)
      game.settle!
      game.settle!
    end

    it "flips into Reflection of Kiki-Jiki, which is not sacrificed as a finished Saga" do
      reach_chapter_3

      expect(saga.name).to eq("Reflection of Kiki-Jiki")
      expect(game.battlefield.permanents).to include(saga)
    end

    it "gains no more lore counters or chapters in later turns" do
      reach_chapter_3

      expect do
        2.times { game.next_turn }
        go_to_main_phase!
        game.settle!
      end.not_to raise_error
      expect(saga.name).to eq("Reflection of Kiki-Jiki")
    end
  end

  context "chapter 2" do
    before do
      2.times { game.next_turn }
      go_to_main_phase!
      game.stack.resolve!
      game.tick!
    end

    it "draws as many cards as were discarded, up to two" do
      cards = [Card("Forest", owner: p1), Card("Island", owner: p1), Card("Plains", owner: p1)]
      cards.each { p1.hand.add(_1) }
      hand_size = p1.hand.count

      game.resolve_choice!(cards: cards.first(2))

      expect(cards.first(2).map(&:zone)).to all(be_graveyard)
      expect(p1.hand.count).to eq(hand_size)
    end

    it "rejects discarding three cards" do
      cards = 3.times.map { Card("Forest", owner: p1).tap { |c| p1.hand.add(c) } }

      expect { game.resolve_choice!(cards: cards) }.to raise_error(ArgumentError)
    end

    it "does nothing when declined" do
      hand_size = p1.hand.count
      game.skip_choice!

      expect(p1.hand.count).to eq(hand_size)
    end
  end
end
