# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FinalVengeance do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Final Vengeance", owner: p1) }
  let!(:target) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { p1.hand.add(card) }

  it "sacrifices a creature as an additional cost and exiles target creature" do
    fodder = ResolvePermanent("Wood Elves", owner: p1)
    p1.add_mana(black: 1)
    p1.cast(card:) do |action|
      action.pay_mana(black: 1)
      action.pay_sacrifice(fodder)
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!

    expect(fodder.card.zone).to be_graveyard
    expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "may sacrifice an enchantment instead" do
    aura = ResolvePermanent("Sanctum Of Calm Waters", owner: p1)
    p1.add_mana(black: 1)
    p1.cast(card:) do |action|
      action.pay_mana(black: 1)
      action.pay_sacrifice(aura)
      action.targeting(target)
    end
    game.stack.resolve!
    game.settle!

    expect(game.exile.cards.map(&:name)).to include("Grizzly Bears")
  end

  it "cannot be cast without sacrificing" do
    p1.add_mana(black: 1)

    expect do
      p1.cast(card:) { |action| action.pay_mana(black: 1).targeting(target) }
    end.to raise_error("Additional costs have not been paid")
  end
end
