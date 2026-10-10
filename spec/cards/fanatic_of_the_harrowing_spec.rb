# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FanaticOfTheHarrowing do
  include_context "two player game"

  let(:mine) { Card("Island", owner: p1) }
  let(:theirs) { Card("Swamp", owner: p2) }

  def resolve_fanatic
    ResolvePermanent("Fanatic Of The Harrowing", owner: p1)
    game.settle!
  end

  it "is a 2/2 Human Cleric" do
    fanatic = ResolvePermanent("Fanatic Of The Harrowing", owner: p1)

    expect([fanatic.power, fanatic.toughness]).to eq([2, 2])
    expect(fanatic.type?("Cleric")).to be(true)
  end

  it "makes each player discard, and draws you a card if you discarded" do
    p1.hand.add(mine)
    p2.hand.add(theirs)
    p1_hand_size = p1.hand.count
    p2_hand_size = p2.hand.count

    resolve_fanatic
    2.times { game.resolve_choice!(card: game.choices.first.player == p1 ? mine : theirs) }

    expect(p1.graveyard.cards).to include(mine)
    expect(p2.graveyard.cards).to include(theirs)
    expect(p1.hand.count).to eq(p1_hand_size)
    expect(p2.hand.count).to eq(p2_hand_size - 1)
  end

  it "does not draw you a card if your hand was empty" do
    p1.hand.cards.dup.each(&:move_to_graveyard!)
    p2.hand.add(theirs)
    p2_hand_size = p2.hand.count

    resolve_fanatic
    game.resolve_choice!(card: theirs)

    expect(p1.hand.count).to eq(0)
    expect(p2.hand.count).to eq(p2_hand_size - 1)
    expect(game.choices).to be_empty
  end
end
