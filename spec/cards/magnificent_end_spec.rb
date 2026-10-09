# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MagnificentEnd do
  include_context "two player game"

  let(:card) { Card("Magnificent End", owner: p1) }
  let!(:bear) { ResolvePermanent("Large Bear", owner: p2) }

  before { p1.hand.add(card) }

  it "deals 5 damage to target creature for its full cost" do
    p1.add_mana(white: 5)
    p1.cast(card:) { |a| a.targeting(bear).pay_mana(generic: { white: 4 }, white: 1) }
    game.stack.resolve!
    expect(p2.graveyard.cards.map(&:name)).to include("Large Bear")
  end

  it "costs {3} less when it targets a tapped creature" do
    bear.tap!
    p1.add_mana(white: 2)
    p1.cast(card:) { |a| a.targeting(bear).pay_mana(generic: { white: 1 }, white: 1) }
    game.stack.resolve!
    expect(p2.graveyard.cards.map(&:name)).to include("Large Bear")
  end

  it "does not get cheaper against an untapped creature" do
    p1.add_mana(white: 2)
    expect {
      p1.cast(card:) { |a| a.targeting(bear).pay_mana(generic: { white: 1 }, white: 1) }
    }.to raise_error(StandardError)
  end
end
