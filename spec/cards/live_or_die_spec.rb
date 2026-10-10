# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LiveOrDie do
  include_context "two player game"

  let(:card) { Card("Live Or Die", owner: p1) }

  before { p1.hand.add(card) }

  it "mode 1 returns target creature card from your graveyard to the battlefield" do
    bears = Card("Grizzly Bears", owner: p1)
    p1.graveyard.add(bears)
    p1.add_mana(black: 5)
    p1.cast(card: card) do |action|
      action.choose_mode(described_class::Mode1) { _1.targeting(bears) }
      action.pay_mana(generic: { black: 3 }, black: 2)
    end
    game.stack.resolve!
    game.tick!

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    expect(p1.graveyard.cards).not_to include(bears)
  end

  it "mode 2 destroys target creature" do
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.add_mana(black: 5)
    p1.cast(card: card) do |action|
      action.choose_mode(described_class::Mode2) { _1.targeting(victim) }
      action.pay_mana(generic: { black: 3 }, black: 2)
    end
    game.stack.resolve!
    game.settle!

    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
  end
end
