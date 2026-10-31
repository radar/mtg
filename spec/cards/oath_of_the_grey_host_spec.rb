# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OathOfTheGreyHost do
  include_context "two player game"

  let(:card) { Card("Oath Of The Grey Host", owner: p1) }

  before do
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(black: 4)
    p1.cast(card: card) { _1.pay_mana(black: 1, generic: { black: 3 }) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  let(:saga) { game.battlefield.by_name("Oath of the Grey Host").first }

  def next_chapter
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  def foods(player) = player.permanents.select { _1.type?("Food") }

  def treasures(player) = player.permanents.select { _1.type?("Treasure") }

  def spirits(player) = player.creatures.select { _1.type?("Spirit") }

  it "enters with a lore counter" do
    expect(saga.counters.of_type(Magic::Counters::Lore).count).to eq(1)
  end

  context "chapter I" do
    # The lone opponent is the only legal target, so the choice resolves itself.
    it "gives you and the target opponent each a Food" do
      expect(game.choices).to be_empty
      expect(foods(p1).count).to eq(1)
      expect(foods(p2).count).to eq(1)
    end
  end

  context "chapter II" do
    before { next_chapter }

    it "makes each opponent lose 3 life, not you" do
      expect(p2.life).to eq(17)
      expect(p1.life).to eq(20)
    end

    it "creates a Treasure for you only" do
      expect(treasures(p1).count).to eq(1)
      expect(treasures(p2).count).to eq(0)
    end
  end

  context "chapter III" do
    before do
      next_chapter
      next_chapter
    end

    it "creates three tapped 1/1 white flying Spirits" do
      expect(spirits(p1).count).to eq(3)
      expect(spirits(p1)).to all(be_tapped)
      expect(spirits(p1)).to all(have_attributes(power: 1, toughness: 1))
      expect(spirits(p1)).to all(have_keyword(:flying))
      expect(spirits(p1).map(&:colors)).to all(eq([:white]))
      expect(spirits(p2).count).to eq(0)
    end

    it "is sacrificed after chapter III" do
      expect(p1.graveyard.by_name("Oath of the Grey Host").count).to eq(1)
    end
  end
end
