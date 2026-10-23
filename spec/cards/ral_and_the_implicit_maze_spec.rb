# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RalAndTheImplicitMaze do
  include_context "two player game"

  def saga = p1.permanents.find { _1.name == "Ral And The Implicit Maze" || _1.name == "Ral and the Implicit Maze" }

  def advance_chapter
    saga.add_counter("lore", amount: 1)
    game.settle!
  end

  context "chapter 1" do
    it "deals 2 damage to each opposing creature, not to the controller's" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      dreadmaw = ResolvePermanent("Colossal Dreadmaw", owner: p2)
      mine = ResolvePermanent("Colossal Dreadmaw", owner: p1)
      ResolvePermanent("Ral And The Implicit Maze", owner: p1)
      game.settle!

      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(dreadmaw.damage).to eq(2)
      expect(mine.damage).to eq(0)
      expect(bears.zone).to be_nil
    end

    it "deals 2 damage to each planeswalker an opponent controls, not your own" do
      theirs = ResolvePermanent("Liliana, Waker Of The Dead", owner: p2)
      mine = ResolvePermanent("Liliana, Waker Of The Dead", owner: p1)
      ResolvePermanent("Ral And The Implicit Maze", owner: p1)
      game.settle!

      expect(theirs.loyalty).to eq(2)
      expect(mine.loyalty).to eq(4)
    end
  end

  context "chapter 2" do
    before do
      ResolvePermanent("Ral And The Implicit Maze", owner: p1)
      game.settle!
      advance_chapter
    end

    it "discards a card, exiles the top two cards and lets you play them" do
      discarded = p1.hand.cards.first
      top = p1.library.cards.first(2)
      game.resolve_choice! # yes, discard
      game.resolve_choice!(card: discarded)

      expect(p1.graveyard.cards).to include(discarded)
      expect(top.map { game.exile.cards.include?(_1) }).to all(be(true))
      expect(top.all? { game.play_permissions.permits?(_1, p1) }).to be(true)
    end

    it "does nothing when you decline" do
      hand_size = p1.hand.cards.count
      game.skip_choice!

      expect(p1.hand.cards.count).to eq(hand_size)
    end
  end

  context "chapter 3" do
    it "creates a Spellgorger Weird token that grows when you cast a noncreature spell" do
      ResolvePermanent("Ral And The Implicit Maze", owner: p1)
      game.settle!
      advance_chapter
      game.skip_choice!
      advance_chapter
      game.settle!

      weird = game.battlefield.by_name("Spellgorger Weird").first
      expect(weird).not_to be_nil
      expect(weird.power).to eq(2)
      expect(weird.mana_value).to eq(3)

      go_to_main_phase!
      shock = Card("Shock", owner: p1)
      p1.hand.add(shock)
      p1.add_mana(red: 1)
      p1.cast(card: shock) { |a| a.pay_mana(red: 1).targeting(p2) }
      game.settle!

      expect(weird.power).to eq(3)

      p1.add_mana(green: 2)
      p1.cast(card: Card("Grizzly Bears", owner: p1)) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.settle!

      expect(weird.power).to eq(3)
    end
  end
end
