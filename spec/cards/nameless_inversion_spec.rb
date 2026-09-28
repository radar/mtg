# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NamelessInversion do
  include_context "two player game"

  let!(:target) { ResolvePermanent("Rampaging Baloths", owner: p2) }

  it "is a changeling Kindred instant" do
    card = Card("Nameless Inversion")
    expect(card.type?(Magic::Types::Kindred)).to eq(true)
    expect(card.type?("Goblin")).to eq(true)
  end

  it "gives +3/-3 and removes creature types until end of turn" do
    p1.add_mana(black: 2)
    p1.hand.add(card = Card("Nameless Inversion"))
    p1.cast(card:) do |action|
      action.pay_mana(black: 1, generic: { black: 1 })
      action.targeting(target)
    end
    game.stack.resolve!
    game.tick!

    expect(target.power).to eq(9)
    expect(target.toughness).to eq(3)
    expect(target.type?("Beast")).to eq(false)
    expect(target.type?("Goblin")).to eq(false)
    expect(target).to be_creature
  end

  it "kills a creature with toughness 3 or less" do
    small = ResolvePermanent("Story Seeker", owner: p2)
    p1.add_mana(black: 2)
    p1.hand.add(card = Card("Nameless Inversion"))
    p1.cast(card:) do |action|
      action.pay_mana(black: 1, generic: { black: 1 })
      action.targeting(small)
    end
    game.stack.resolve!
    game.tick!

    expect(p2.graveyard.cards.map(&:name)).to include("Story Seeker")
  end
end
