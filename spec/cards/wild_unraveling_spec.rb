# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WildUnraveling do
  include_context "two player game"

  let(:card) { Card("Wild Unraveling", owner: p1) }

  before { p1.hand.add(card) }

  def cast_bolt
    bolt = Card("Lightning Bolt", owner: p2)
    p2.hand.add(bolt)
    p2.add_mana(red: 1)
    p2.cast(card: bolt) { |a| a.pay_mana(red: 1).targeting(p1) }
  end

  it "counters target spell" do
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_bolt
    p1.add_mana(blue: 2)

    p1.cast(card:) { |a| a.pay_mana(blue: 2).pay_blight_or_mana(own_bears).targeting(game.stack.spells.first) }
    game.stack.resolve!

    expect(p1.life).to eq(20)
  end

  it "can pay the additional cost by blighting a creature you control" do
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    cast_bolt
    p1.add_mana(blue: 2)

    p1.cast(card:) { |a| a.pay_mana(blue: 2).pay_blight_or_mana(own_bears).targeting(game.stack.spells.first) }

    expect(own_bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(2)
  end

  it "can pay the additional cost with {1} instead" do
    cast_bolt
    p1.add_mana(blue: 3)

    p1.cast(card:) { |a| a.pay_mana(blue: 2).pay_blight_or_mana(generic: { blue: 1 }).targeting(game.stack.spells.first) }

    expect(p1.mana_pool[:blue]).to eq(0)
    expect(game.stack.spells.map(&:card)).to include(card)
  end
end
