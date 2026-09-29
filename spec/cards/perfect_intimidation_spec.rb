# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PerfectIntimidation do
  include_context "two player game"

  let(:card) { Card("Perfect Intimidation", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before do
    p1.hand.add(card)
    go_to_main_phase!
  end

  def cast_with(*modes)
    p1.add_mana(black: 4)
    p1.cast(card: card) do |action|
      action.pay_mana(black: 1, generic: { black: 3 })
      modes.each { |mode, *targets| action.choose_mode(mode) { _1.targeting(*targets) } }
    end
    game.stack.resolve!
  end

  it "makes target opponent exile two cards from their hand, their choice" do
    hand = 3.times.map { Card("Forest", owner: p2) }
    hand.each { p2.hand.add(_1) }
    before = p2.hand.count
    cast_with([described_class::ExileTwo, p2])

    expect(game.choices.last.player).to eq(p2)
    game.resolve_choice!(cards: hand.first(2))
    expect(hand.first(2).map(&:zone)).to all(be_exile)
    expect(p2.hand.count).to eq(before - 2)
  end

  it "makes them exile their whole hand when it has fewer than two cards" do
    lone = Card("Forest", owner: p2)
    p2.hand.cards.to_a.dup.each(&:discard!)
    p2.hand.add(lone)
    cast_with([described_class::ExileTwo, p2])
    game.resolve_choice!(cards: [lone])
    expect(lone.zone).to be_exile
  end

  it "asks for nothing when their hand is empty" do
    p2.hand.cards.to_a.dup.each(&:discard!)
    cast_with([described_class::ExileTwo, p2])
    expect(game.choices).to be_empty
  end

  it "rejects the wrong number of cards" do
    2.times { p2.hand.add(Card("Forest", owner: p2)) }
    cast_with([described_class::ExileTwo, p2])
    expect { game.resolve_choice!(cards: [p2.hand.cards.first]) }.to raise_error(ArgumentError, /exile 2 cards/)
  end

  it "removes all counters from target creature" do
    bears.add_counter("+1/+1", amount: 2)
    bears.add_counter("stun")
    cast_with([described_class::RemoveCounters, bears])
    expect(bears.counters.count).to eq(0)
  end

  it "does both when both are chosen" do
    2.times { p2.hand.add(Card("Forest", owner: p2)) }
    bears.add_counter("stun")
    cast_with([described_class::ExileTwo, p2], [described_class::RemoveCounters, bears])
    game.resolve_choice!(cards: p2.hand.cards.to_a.first(2))
    expect(bears.counters.count).to eq(0)
  end

  it "needs at least one mode and at most both" do
    p1.add_mana(black: 4)
    expect { p1.cast(card: card) { |a| a.pay_mana(black: 1, generic: { black: 3 }) } }.to raise_error(Magic::Actions::Cast::InvalidModes)
  end
end
