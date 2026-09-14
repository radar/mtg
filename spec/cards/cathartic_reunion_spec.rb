# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CatharticReunion do
  include_context "two player game"

  let(:card) { Card("Cathartic Reunion", owner: p1) }
  let(:discard_one) { Card("Grizzly Bears", owner: p1) }
  let(:discard_two) { Card("Island", owner: p1) }

  before do
    p1.hand.add(card)
    p1.hand.add(discard_one)
    p1.hand.add(discard_two)
  end

  it "discards two cards as an additional cost and draws three cards" do
    hand_size = p1.hand.count
    p1.add_mana(red: 2)
    p1.cast(card: card) do |action|
      action.pay_mana(generic: { red: 1 }, red: 1)
      action.pay_discard([discard_one, discard_two])
    end

    expect(discard_one.zone).to be_graveyard
    expect(discard_two.zone).to be_graveyard

    game.stack.resolve!

    expect(p1.hand.count).to eq(hand_size)
  end

  it "raises if the wrong number of cards is discarded" do
    p1.add_mana(red: 2)

    expect do
      p1.cast(card: card) do |action|
        action.pay_mana(generic: { red: 1 }, red: 1)
        action.pay_discard([discard_one])
      end
    end.to raise_error(/Must discard 2 cards/)
  end
end
