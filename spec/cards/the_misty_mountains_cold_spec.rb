# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheMistyMountainsCold do
  include_context "two player game"

  let(:card) { Card("The Misty Mountains Cold", owner: p1) }

  def treasures = p1.permanents.select { _1.type?("Treasure") }

  def dragons = p1.creatures.select { _1.type?("Dragon") }

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

  it "I — creates a Treasure" do
    expect(treasures.count).to eq(1)
  end

  it "II and III — create another Treasure each, with no Dragon yet" do
    2.times { next_chapter }

    expect(treasures.count).to eq(3)
    expect(dragons).to be_empty
  end

  it "IV — the fourth Treasure sacrifices the Saga for a 6/6 flying Dragon" do
    3.times { next_chapter }

    expect(treasures.count).to eq(4)
    expect(dragons.count).to eq(1)
    expect([dragons.first.power, dragons.first.toughness]).to eq([6, 6])
    expect(dragons.first).to have_keyword(:flying)
    expect(p1.permanents.map(&:name)).not_to include("The Misty Mountains Cold")
  end

  it "sacrifices the Saga for a Dragon early if you already control four Treasures" do
    3.times { Magic::Tokens::Treasure.new(game: game, owner: p1).resolve! }
    next_chapter

    expect(dragons.count).to eq(1)
    expect(p1.permanents.map(&:name)).not_to include("The Misty Mountains Cold")
  end
end
