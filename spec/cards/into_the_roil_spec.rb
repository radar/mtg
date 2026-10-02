# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::IntoTheRoil do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:anthem) { ResolvePermanent("Anthem Of Champions", owner: p2) }

  it "returns target nonland permanent to its owner's hand" do
    hand_size = p1.hand.count
    p1.add_mana(blue: 2)
    p1.cast(card: Card("Into The Roil", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(rival) }
    game.stack.resolve!

    expect(rival.card.zone).to be_hand
    expect(p1.hand.count).to eq(hand_size)
  end

  it "can bounce a noncreature permanent" do
    p1.add_mana(blue: 2)
    p1.cast(card: Card("Into The Roil", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(anthem) }
    game.stack.resolve!

    expect(anthem.card.zone).to be_hand
  end

  it "draws a card when kicked" do
    hand_size = p1.hand.count
    p1.add_mana(blue: 4)
    p1.cast(card: Card("Into The Roil", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).pay_kicker(generic: { blue: 1 }, blue: 1).targeting(rival) }
    game.stack.resolve!

    expect(p1.hand.count).to eq(hand_size + 1)
  end

  it "can't target a land" do
    land = ResolvePermanent("Forest", owner: p2)
    p1.add_mana(blue: 2)

    expect { p1.cast(card: Card("Into The Roil", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(land) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
