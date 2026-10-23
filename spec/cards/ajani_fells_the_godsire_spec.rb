# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AjaniFellsTheGodsire do
  include_context "two player game"

  let(:card) { Card("Ajani Fells The Godsire", owner: p1) }
  let!(:ally) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:big) { ResolvePermanent("Colossal Dreadmaw", owner: p2) }
  let!(:small) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def next_chapter
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  before do
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(white: 5)
    p1.cast(card: card) { _1.pay_mana(white: 2, generic: { white: 3 }) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "I — exiles an opponent's creature with power 3 or greater" do
    expect(game.exile.cards.map(&:name)).to eq(["Colossal Dreadmaw"])
    expect(p2.creatures.map(&:name)).to eq(["Grizzly Bears"])
  end

  context "chapter II" do
    before { next_chapter }

    it "creates a 2/1 Cat Warrior and puts a vigilance counter on a creature you control" do
      cat = p1.creatures.find { _1.name == "Cat Warrior" }
      expect([cat.power, cat.toughness]).to eq([2, 1])

      game.resolve_choice!(target: ally)
      game.tick!

      expect(ally.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to eq(true)
      expect(cat.has_keyword?(Magic::Cards::Keywords::VIGILANCE)).to eq(false)
    end
  end

  context "chapter III" do
    before do
      next_chapter
      game.resolve_choice!(target: ally)
      next_chapter
    end

    it "gives a creature you control double strike" do
      game.resolve_choice!(target: ally)
      game.tick!

      expect(ally.double_strike?).to eq(true)
    end
  end
end
