# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BookOfMazarbul do
  include_context "two player game"

  let(:card) { Card("Book of Mazarbul", owner: p1) }

  def army = p1.creatures.find { _1.type?("Army") }

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
    p1.add_mana(red: 3)
    p1.cast(card:) { _1.pay_mana(generic: { red: 2 }, red: 1) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "I — amasses Orcs 1, creating a 1/1 black Orc Army" do
    expect(army.type?("Orc")).to eq(true)
    expect([army.power, army.toughness]).to eq([1, 1])
  end

  context "after chapter I" do
    it "II — amasses Orcs 2 onto the existing Army" do
      next_chapter
      expect(p1.creatures.count { _1.type?("Army") }).to eq(1)
      expect(army.power).to eq(3)
    end

    it "III — gives your creatures +1/+0 and menace until end of turn, not the opponent's, then sacrifices" do
      next_chapter
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      next_chapter
      game.tick!

      expect(mine.power).to eq(3)
      expect(mine.menace?).to eq(true)
      expect(army.power).to eq(4)
      expect(theirs.power).to eq(2)
      expect(theirs.menace?).to eq(false)
      expect(p1.graveyard.cards.map(&:name)).to include("Book of Mazarbul")
    end

    it "III — the bonus ends at end of turn" do
      next_chapter
      mine = ResolvePermanent("Grizzly Bears", owner: p1)
      next_chapter
      game.current_turn.end!
      game.current_turn.cleanup!
      game.tick!
      expect(mine.power).to eq(2)
      expect(mine.menace?).to eq(false)
    end
  end
end
