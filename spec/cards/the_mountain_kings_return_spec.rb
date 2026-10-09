# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheMountainKingsReturn do
  include_context "two player game"

  let(:card) { Card("The Mountain King's Return", owner: p1) }

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
    p1.add_mana(white: 3)
    p1.cast(card:) { _1.pay_mana(generic: { white: 2 }, white: 1) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "I — recruits: loot, and a Human Soldier if a nonland card was discarded" do
    expect(game.choices.last).to be_a(Magic::Choice::Discard)
    nonland = Card("Grizzly Bears", owner: p1)
    p1.hand.add(nonland)
    game.resolve_choice!(card: nonland)

    expect(p1.creatures.select { _1.name == "Human Soldier" }.count).to eq(1)
  end

  it "I — makes no Soldier when a land is discarded" do
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    game.resolve_choice!(card: land)

    expect(p1.creatures.select { _1.name == "Human Soldier" }).to be_empty
  end

  context "after chapter I" do
    before do
      land = Card("Forest", owner: p1)
      p1.hand.add(land)
      game.resolve_choice!(card: land)
    end

    it "II — returns a creature card with mana value 3 or less from your graveyard" do
      bears = Card("Grizzly Bears", owner: p1)
      big = Card("Axegrinder Giant", owner: p1)
      elves = Card("Wood Elves", owner: p1)
      p1.graveyard.add(bears)
      p1.graveyard.add(elves)
      p1.graveyard.add(big)
      next_chapter

      expect(game.choices.last.choices).to contain_exactly(bears, elves)
      game.resolve_choice!(target: bears)
      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "III — puts a +1/+1 counter on up to one target creature, then the Saga is sacrificed" do
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      next_chapter
      next_chapter
      game.resolve_choice!(target: mine)
      game.tick!

      expect(mine.power).to eq(3)
      expect(theirs.power).to eq(2)
      expect(p1.graveyard.cards.map(&:name)).to include("The Mountain-king's Return")
    end
  end
end
