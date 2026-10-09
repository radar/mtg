# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheMasterOfLakeTown do
  include_context "two player game"

  let!(:master) { ResolvePermanent("The Master Of Lake Town", owner: p1) }

  it "has deathtouch" do
    expect(master).to have_keyword(:deathtouch)
  end

  it "makes a player who loses life mill that many cards" do
    library_before = p2.library.count
    graveyard_before = p2.graveyard.count
    p2.lose_life(3)
    game.settle!

    expect(p2.library.count).to eq(library_before - 3)
    expect(p2.graveyard.count).to eq(graveyard_before + 3)
  end

  it "also mills its controller when they lose life" do
    library_before = p1.library.count
    p1.lose_life(2)
    game.settle!

    expect(p1.library.count).to eq(library_before - 2)
  end

  it "draws a card for each graveyard with seven or more cards when it dies" do
    7.times { p1.graveyard.add(Card("Forest", owner: p1)) }
    7.times { p2.graveyard.add(Card("Forest", owner: p2)) }
    hand_before = p1.hand.count
    master.destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand_before + 2)
  end

  it "draws nothing when no graveyard has seven cards" do
    hand_before = p1.hand.count
    master.destroy!
    game.settle!

    expect(p1.hand.count).to eq(hand_before)
  end
end
