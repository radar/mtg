# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DownInTheValley do
  include_context "two player game"

  let(:card) { Card("Down In The Valley", owner: p1) }
  let!(:forest) { Card("Forest", owner: p1) }

  def saga = p1.permanents.find { _1.name == "Down in the Valley" }
  def elves = p1.creatures.select { _1.type?("Elf") }

  def next_chapter
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  def play_land
    land = Card("Forest", owner: p1)
    p1.hand.add(land)
    p1.play_land(land: land)
    game.settle!
  end

  before do
    p1.library.add(forest)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(green: 3)
    p1.cast(card:) { _1.pay_mana(generic: { green: 2 }, green: 1) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "I — searches for a basic land card and puts it into your hand" do
    game.resolve_choice!(targets: [forest])
    expect(forest.zone).to be_hand
  end

  it "has no landfall ability before chapter II" do
    game.resolve_choice!(targets: [forest])
    play_land
    expect(elves).to be_empty
  end

  context "after chapter II" do
    before do
      game.resolve_choice!(targets: [forest])
      next_chapter
    end

    it "II — creates a 1/1 green Elf whenever a land you control enters" do
      expect { play_land }.to change { elves.count }.by(1)
      expect([elves.first.power, elves.first.toughness]).to eq([1, 1])
    end

    it "III — Elves you control get +1/+0 and vigilance until end of turn" do
      play_land
      next_chapter
      elf = elves.first
      expect(elf.power).to eq(2)
      expect(elf.keywords).to include(Magic::Cards::Keywords::VIGILANCE)
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      expect(bears.power).to eq(2)
    end

    it "IV — gives Elves +1/+0 and vigilance again, then the Saga is sacrificed" do
      play_land
      next_chapter
      next_chapter
      expect(elves.first.power).to eq(2)
      expect(p1.graveyard.cards.map(&:name)).to include("Down in the Valley")
    end

    it "wears off at end of turn" do
      play_land
      next_chapter
      expect(elves.first.power).to eq(2)
      current_turn.end!
      current_turn.cleanup!
      resolve_cleanup_discards!
      expect(elves.first.power).to eq(1)
    end
  end
end
