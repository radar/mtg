# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MiasmaDemon do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:hand_cards) { [Card("Forest", owner: p1), Card("Forest", owner: p1)] }

  before do
    hand_cards.each { |card| p1.hand.add(card) }
    ResolvePermanent("Miasma Demon", owner: p1)
  end

  it "is a 5/4 flyer" do
    demon = p1.creatures.find { _1.name == "Miasma Demon" }
    expect(demon.power).to eq(5)
    expect(demon.toughness).to eq(4)
    expect(demon).to be_flying
  end

  it "lets you discard cards, then shrinks up to that many creatures" do
    game.resolve_choice!(choices: hand_cards)
    game.settle!
    game.resolve_choice!(targets: [bears, other_bears])
    game.settle!

    expect(p1.graveyard.cards.count { _1.name == "Forest" }).to eq(2)
    expect(p2.creatures).to be_empty
  end

  it "caps the targets at the number of cards discarded" do
    game.resolve_choice!(choices: [hand_cards.first])
    game.settle!
    game.resolve_choice!(targets: [bears, other_bears])
    game.settle!

    expect(p2.creatures.count).to eq(1)
  end

  it "does nothing if you discard nothing" do
    game.resolve_choice!(choices: [])
    game.settle!

    expect(p2.creatures.count).to eq(2)
    expect(game.choices).to be_empty
  end
end
