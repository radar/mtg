# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BogslithersEmbrace do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Bogslither's Embrace", owner: p1) }

  it "exiles target creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(black: 2)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 1).pay_blight_or_mana(own_bears).targeting(bears) }
    game.stack.resolve!

    expect(bears.card.zone).to be_exile
  end

  it "can pay the additional cost by blighting a creature you control" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(black: 2)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 1).pay_blight_or_mana(own_bears).targeting(bears) }

    expect(own_bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
  end

  it "can pay the additional cost with {3} instead" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(black: 5)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 1).pay_blight_or_mana(generic: { black: 3 }).targeting(bears) }

    expect(p1.mana_pool[:black]).to eq(0)
    expect(game.stack.spells.map(&:card)).to eq([card])
  end

  it "cannot be cast without paying the additional cost" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(black: 2)
    p1.hand.add(card)

    expect { p1.cast(card:) { |a| a.pay_mana(generic: { black: 1 }, black: 1).targeting(bears) } }
      .to raise_error(/Additional costs have not been paid/)
  end
end
