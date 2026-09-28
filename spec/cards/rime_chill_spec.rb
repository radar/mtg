# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RimeChill do
  include_context "two player game"

  let(:chill) { Card("Rime Chill", owner: p1) }

  before { p1.hand.add(chill) }

  it "costs {1} less for each color among permanents you control" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Alaborn Trooper", owner: p1)

    expect(Magic::Actions::Cast.new(card: chill, player: p1, game: game).mana_cost.cost[:generic]).to eq(4)
  end

  it "taps up to two creatures, stuns each, and draws a card" do
    a = ResolvePermanent("Grizzly Bears", owner: p2)
    b = ResolvePermanent("Alaborn Trooper", owner: p2)
    hand = p1.hand.cards.count
    p1.add_mana(blue: 7)
    p1.cast(card: chill) do |action|
      action.pay_mana(blue: 1, generic: { blue: 6 })
      action.targeting(a, b)
    end
    game.stack.resolve!

    expect([a, b]).to all(be_tapped)
    expect([a, b].map { _1.counters.of_type(Magic::Counters::Stun).count }).to eq([1, 1])
    expect(p1.hand.cards.count).to eq(hand) # +1 (the spell) -1 (cast) +1 (draw)
  end

  it "can be cast with no targets and still draws" do
    hand = p1.hand.cards.count
    p1.add_mana(blue: 7)
    p1.cast(card: chill) { |action| action.pay_mana(blue: 1, generic: { blue: 6 }) }
    game.stack.resolve!

    expect(p1.hand.cards.count).to eq(hand)
  end
end
