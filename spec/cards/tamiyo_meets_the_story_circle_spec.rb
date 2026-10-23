# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TamiyoMeetsTheStoryCircle do
  include_context "two player game"

  let!(:saga) { ResolvePermanent("Tamiyo Meets The Story Circle", owner: p1, summoning_sick: true) }

  def advance_chapter
    saga.add_counter("lore", amount: 1)
    game.settle!
  end

  def clues = p1.permanents.select { _1.name == "Clue" }

  context "chapter 1" do
    it "gives -2/-0 to a creature attacking you until your next turn" do
      attacker = ResolvePermanent("Colossal Dreadmaw", owner: p2)
      game.next_turn
      go_to_main_phase!
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(attacker, target: p1)
      current_turn.attackers_declared!
      game.settle!

      expect(attacker.power).to eq(4)
    end

    it "still applies after the Saga has left the battlefield" do
      attacker = ResolvePermanent("Colossal Dreadmaw", owner: p2)
      saga.destroy!
      game.settle!
      game.next_turn
      go_to_main_phase!
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(attacker, target: p1)
      current_turn.attackers_declared!
      game.settle!

      expect(attacker.power).to eq(4)
    end

    it "stops applying once your next turn begins" do
      attacker = ResolvePermanent("Colossal Dreadmaw", owner: p2)
      2.times { game.next_turn }
      go_to_main_phase!
      game.skip_choice! while game.choices.any?
      game.next_turn
      go_to_main_phase!
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(attacker, target: p1)
      current_turn.attackers_declared!
      game.settle!

      expect(attacker.power).to eq(6)
    end

    it "does nothing to a creature attacking someone else" do
      mine = ResolvePermanent("Colossal Dreadmaw", owner: p1)
      go_to_main_phase!
      game.settle!
      game.skip_choice! if game.choices.any?
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(mine, target: p2)
      current_turn.attackers_declared!
      game.settle!

      expect(mine.power).to eq(6)
    end
  end

  context "chapter 2" do
    before { advance_chapter }

    it "discards cards and investigates twice for each" do
      hand = p1.hand.cards.first(2)
      game.resolve_choice!(choices: hand)

      expect(p1.graveyard.cards).to include(*hand)
      expect(clues.count).to eq(4)
    end

    it "investigates not at all when discarding nothing" do
      game.skip_choice!

      expect(clues.count).to eq(0)
    end
  end

  context "chapter 3" do
    it "shuffles up to three cards from your graveyard into your library" do
      cards = p1.hand.cards.first(3)
      cards.each(&:move_to_graveyard!)
      advance_chapter
      game.skip_choice!
      advance_chapter
      game.resolve_choice!(targets: cards)

      expect(p1.graveyard.cards).not_to include(*cards)
      expect(p1.library.cards).to include(*cards)
    end
  end
end
