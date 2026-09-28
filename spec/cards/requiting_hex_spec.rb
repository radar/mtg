# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RequitingHex do
  include_context "two player game"

  let(:card) { Card("Requiting Hex", owner: p1) }

  it "destroys target creature with mana value 2 or less" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(black: 1)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(black: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears.card.zone).to be_graveyard
    expect(p1.life).to eq(20)
  end

  it "cannot target a creature with mana value 3 or more" do
    big = ResolvePermanent("Courser Of Kruphix", owner: p2)
    p1.add_mana(black: 1)
    p1.hand.add(card)

    expect { p1.cast(card:) { |a| a.pay_mana(black: 1).targeting(big) } }.to raise_error(StandardError)
  end

  it "gains 2 life if you blighted a creature as the additional cost" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    own_bears = ResolvePermanent("Courser Of Kruphix", owner: p1)
    p1.add_mana(black: 1)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(black: 1).pay_kicker(own_bears).targeting(bears) }
    game.stack.resolve!

    expect(own_bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
    expect(bears.card.zone).to be_graveyard
    expect(p1.life).to eq(22)
  end
end
