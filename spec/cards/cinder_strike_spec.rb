# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CinderStrike do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Cinder Strike", owner: p1) }

  it "deals 2 damage to target creature" do
    target = ResolvePermanent("Courser Of Kruphix", owner: p2)
    p1.add_mana(red: 1)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(red: 1).targeting(target) }
    game.stack.resolve!

    expect(target.damage).to eq(2)
  end

  it "deals 4 damage if you blighted a creature as the additional cost" do
    target = ResolvePermanent("Courser Of Kruphix", owner: p2)
    own_bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(red: 1)
    p1.hand.add(card)

    p1.cast(card:) { |a| a.pay_mana(red: 1).pay_kicker(own_bears).targeting(target) }
    game.stack.resolve!

    expect(own_bears.counters.of_type(Magic::Counters::Minus1Minus1).count).to eq(1)
    expect(target.damage).to eq(4)
  end
end
