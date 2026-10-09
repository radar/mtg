# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OinTheBrave do
  include_context "two player game"

  let!(:oin) { ResolvePermanent("Oin The Brave", owner: p1) }

  it "is a 1/3 without an enduring story" do
    game.tick!

    expect([oin.power, oin.toughness]).to eq([1, 3])
    expect(oin).not_to have_keyword(:haste)
  end

  it "gets +1/+0 and haste once you control three artifacts, legendaries and/or Sagas" do
    2.times { ResolvePermanent("Well-Worn Spatula", owner: p1) }
    game.tick!

    expect(oin.power).to eq(2)
    expect(oin).to have_keyword(:haste)
  end

  it "keeps the enduring story after the permanents leave" do
    spatulas = Array.new(2) { ResolvePermanent("Well-Worn Spatula", owner: p1) }
    game.tick!
    spatulas.each(&:destroy!)
    game.settle!
    game.tick!

    expect(oin.power).to eq(2)
    expect(oin).to have_keyword(:haste)
  end

  it "loots: {1}, {T}, discard a card: draw a card" do
    p1.add_mana(red: 1)
    card = p1.hand.cards.first
    library_before = p1.library.count
    p1.activate_ability(ability: oin.activated_abilities.first) do
      _1.pay_mana(generic: { red: 1 })
      _1.pay_discard(card) if _1.respond_to?(:pay_discard)
    end
    game.stack.resolve!

    expect(p1.library.count).to eq(library_before - 1)
    expect(oin).to be_tapped
    expect(card.zone).to be_graveyard
  end
end
