# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CribSwap do
  include_context "two player game"

  it "exiles the creature and gives its controller a changeling Shapeshifter" do
    target = ResolvePermanent("Loch Mare", owner: p2)
    p1.add_mana(white: 3)
    p1.hand.add(card = Card("Crib Swap"))
    p1.cast(card:) do |action|
      action.pay_mana(white: 1, generic: { white: 2 })
      action.targeting(target)
    end
    game.stack.resolve!
    game.tick!

    expect(target.card.zone).to be_exile
    token = p2.creatures.first
    expect(token).to be_token
    expect(token.name).to eq("Shapeshifter")
    expect(token.power).to eq(1)
    expect(token.changeling?).to eq(true)
    expect(p1.creatures).to be_empty
  end
end
