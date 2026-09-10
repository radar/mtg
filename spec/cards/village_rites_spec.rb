# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VillageRites do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }
  subject(:village_rites) { Card("Village Rites", owner: p1) }

  before do
    p1.hand.add(village_rites)
  end

  it "sacrifices a creature as an additional cost and draws two cards" do
    hand_size = p1.hand.count
    p1.add_mana(black: 1)
    p1.cast(card: village_rites) do |action|
      action.pay_mana(black: 1)
      action.pay_sacrifice(wood_elves)
    end

    game.stack.resolve!

    expect(wood_elves.card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "cannot be cast without sacrificing a creature" do
    p1.add_mana(black: 1)
    expect do
      p1.cast(card: village_rites) do |action|
        action.pay_mana(black: 1)
      end
    end.to raise_error("Additional costs have not been paid")
  end
end
