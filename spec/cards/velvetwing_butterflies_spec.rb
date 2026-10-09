# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VelvetwingButterflies do
  include_context "two player game"

  let(:card) { Card("Velvetwing Butterflies", owner: p1) }

  before { p1.hand.add(card) }

  it "is a 2/2 flyer" do
    butterflies = ResolvePermanent("Velvetwing Butterflies", owner: p1)

    expect([butterflies.power, butterflies.toughness]).to eq([2, 2])
    expect(butterflies).to have_keyword(:flying)
  end

  it "casts Gaze in Wonder to tap one target creature, then exiles on an adventure" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(white: 2)
    p1.cast(card:, adventure: true) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
    game.stack.resolve!

    expect(bears).to be_tapped
    expect(card.zone).to be_exile
    expect(card.on_adventure).to eq(true)
  end

  it "taps two target creatures" do
    one = ResolvePermanent("Grizzly Bears", owner: p2)
    two = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(white: 2)
    p1.cast(card:, adventure: true) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(one, two) }
    game.stack.resolve!

    expect([one, two]).to all(be_tapped)
  end

  it "can be cast at instant speed as an adventure" do
    go_to_main_phase_for!(p2)
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(white: 2)

    expect { p1.cast(card:, adventure: true) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) } }.not_to raise_error
  end

  it "can then be cast as the creature from exile" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(white: 2)
    p1.cast(card:, adventure: true) { _1.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
    game.stack.resolve!
    go_to_main_phase!
    p1.add_mana(white: 3)
    p1.cast(card:) { _1.pay_mana(generic: { white: 2 }, white: 1) }
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to include("Velvetwing Butterflies")
  end
end
