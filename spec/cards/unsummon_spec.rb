# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Unsummon do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "returns target creature to its owner's hand" do
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Unsummon", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(rival) }
    game.stack.resolve!

    expect(rival.card.zone).to be_hand
    expect(p2.hand.cards).to include(rival.card)
  end

  it "can bounce your own creature" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Unsummon", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(mine) }
    game.stack.resolve!

    expect(mine.card.zone).to be_hand
  end
end
