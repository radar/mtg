# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KineticAugur do
  include_context "two player game"

  let(:augur) { ResolvePermanent("Kinetic Augur", owner: p1) }

  it "has toughness 4 and trample" do
    game.skip_choice! if game.choices.any?
    expect(augur.toughness).to eq(4)
    expect(augur.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(true)
  end

  it "has power equal to the instant and sorcery cards in your graveyard" do
    augur
    game.skip_choice! if game.choices.any?
    expect(augur.power).to eq(0)

    p1.graveyard.add(Card("Lightning Bolt", owner: p1))
    p1.graveyard.add(Card("Duress", owner: p1))
    p1.graveyard.add(Card("Grizzly Bears", owner: p1))
    game.tick!

    expect(augur.power).to eq(2)
  end

  it "discards up to two cards and draws that many when it enters" do
    hand = p1.hand.cards.first(2)
    library_count = p1.library.count
    augur

    game.resolve_choice!(discarded: hand)

    expect(hand.map(&:zone)).to all(be_graveyard)
    expect(p1.library.count).to eq(library_count - 2)
  end

  it "may discard nothing" do
    hand_size = p1.hand.count
    augur
    game.resolve_choice!(discarded: [])

    expect(p1.hand.count).to eq(hand_size)
  end
end
