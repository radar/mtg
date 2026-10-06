# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PestilentHaze do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast(mode)
    card = Card("Pestilent Haze", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) do |action|
      action.pay_mana(generic: { black: 1 }, black: 2)
      action.choose_mode(mode)
    end
    game.stack.resolve!
    game.settle!
  end

  it "gives all creatures -2/-2 until end of turn" do
    mine = ResolvePermanent("Serra Angel", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    cast(described_class::ShrinkCreatures)

    expect([mine.power, mine.toughness]).to eq([2, 2])
    expect(theirs.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "removes two loyalty counters from each planeswalker" do
    mine = ResolvePermanent("Ob Nixilis Reignited", owner: p1)
    theirs = ResolvePermanent("Jaya Ballard", owner: p2)
    cast(described_class::RemoveLoyalty)

    expect(mine.loyalty).to eq(3)
    expect(theirs.loyalty).to eq(3)
  end
end
