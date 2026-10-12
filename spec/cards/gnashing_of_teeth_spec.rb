# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GnashingOfTeeth do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Gnashing of Teeth") }

  it "mode 1 gives a creature -5/-5 and exiles it if it dies" do
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(black: 3)
    p1.cast(card: card) do |action|
      action.choose_mode(described_class::Mode1) { _1.targeting(victim) }
      action.pay_mana(generic: { black: 1 }, black: 2)
    end
    game.stack.resolve!
    game.tick!
    game.settle!

    expect(p2.graveyard.cards).to be_empty
    expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "mode 2 gives creatures target player controls -1/-1" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(black: 3)
    p1.cast(card: card) do |action|
      action.choose_mode(described_class::Mode2) { _1.targeting(p2) }
      action.pay_mana(generic: { black: 1 }, black: 2)
    end
    game.stack.resolve!
    game.tick!

    expect(theirs.power).to eq(1)
    expect(mine.power).to eq(2)
  end
end
