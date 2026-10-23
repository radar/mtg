# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RefurbishedFamiliar do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:familiar) { Card("Refurbished Familiar", owner: p1).tap { p1.hand.add(_1) } }

  it "is a 2/1 artifact flyer" do
    permanent = ResolvePermanent("Refurbished Familiar", owner: p1)
    game.settle!
    expect(permanent.power).to eq(2)
    expect(permanent.toughness).to eq(1)
    expect(permanent.type?("Artifact")).to be(true)
    expect(permanent.flying?).to be(true)
  end

  it "costs {1} less for each artifact you control" do
    ResolvePermanent("Refurbished Familiar", owner: p1)
    ResolvePermanent("Refurbished Familiar", owner: p1)
    game.settle!
    p1.add_mana(black: 2) # two artifacts: {3}{B} costs {1}{B}
    p1.cast(card: familiar) { |a| a.pay_mana(black: 1, generic: { black: 1 }) }
    game.stack.resolve!
    game.settle!
    expect(p1.creatures.map(&:name)).to include("Refurbished Familiar")
  end

  it "makes each opponent discard a card" do
    ResolvePermanent("Refurbished Familiar", owner: p1)
    game.settle!
    discard = p2.hand.cards.first
    game.resolve_choice!(card: discard)

    expect(p2.graveyard.cards).to include(discard)
  end

  it "draws a card when the opponent has none to discard" do
    p2.hand.cards.dup.each(&:move_to_graveyard!)
    hand_size = p1.hand.count
    ResolvePermanent("Refurbished Familiar", owner: p1)
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
  end
end
