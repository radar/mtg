# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BurnBurnTreeAndFern do
  include_context "two player game"

  let!(:theirs) { ResolvePermanent("Baneslayer Angel", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:their_artifact) { ResolvePermanent("Sol Ring", owner: p2) }
  let(:card) { Card("Burn Burn Tree And Fern", owner: p1) }

  before do
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(red: 4)
    p1.cast(card: card) { _1.pay_mana(red: 1, generic: { red: 3 }) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  let(:saga) { game.battlefield.by_name("Burn, Burn, Tree and Fern").first }

  def next_chapter
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "I -- deals 6 damage to target creature an opponent controls" do
    expect(p2.graveyard.cards.map(&:name)).to include("Baneslayer Angel")
    expect(mine.damage).to eq(0)
  end

  it "II -- destroys target artifact an opponent controls" do
    next_chapter

    expect(p2.graveyard.cards.map(&:name)).to include("Sol Ring")
  end

  it "III -- adds {R}" do
    2.times { next_chapter }

    expect(p1.mana_pool[:red]).to be >= 1
  end

  it "IV -- adds {R}, then is sacrificed" do
    3.times { next_chapter }

    expect(p1.mana_pool[:red]).to be >= 1
    expect(p1.graveyard.cards.map(&:name)).to include("Burn, Burn, Tree and Fern")
  end
end
