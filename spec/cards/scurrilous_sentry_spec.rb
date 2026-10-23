# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ScurrilousSentry do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:land) { Card("Island", owner: p1) }

  def counters(permanent) = permanent.power - 2

  it "is a 2/3 with menace" do
    sentry = ResolvePermanent("Scurrilous Sentry", owner: p1)
    expect(sentry.power).to eq(2)
    expect(sentry.keywords).to include(Magic::Cards::Keywords::MENACE)
  end

  it "connives when it enters: draws, then a nonland discard adds a counter" do
    hand_size = p1.hand.count
    sentry = ResolvePermanent("Scurrilous Sentry", owner: p1)
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
    discard = p1.hand.cards.find { !_1.land? } || p1.hand.cards.first
    game.resolve_choice!(card: discard)

    expect(p1.hand.count).to eq(hand_size)
    expect(counters(sentry)).to eq(discard.land? ? 0 : 1)
  end

  it "gets no counter when it discards a land" do
    sentry = ResolvePermanent("Scurrilous Sentry", owner: p1)
    game.settle!
    island = Card("Island", owner: p1)
    p1.hand.add(island)
    game.resolve_choice!(card: island)

    expect(counters(sentry)).to eq(0)
    expect(p1.graveyard.cards).to include(island)
  end

  it "connives whenever it attacks" do
    sentry = ResolvePermanent("Scurrilous Sentry", owner: p1)
    game.resolve_choice!(card: p1.hand.cards.first) # the enters connive
    game.settle!
    hand_size = p1.hand.count
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: sentry, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(p1.hand.count).to eq(hand_size + 1)
    expect(game.choices.first).to be_a(Magic::Choice::Connive)
  end

  it "gets a counter when it discards a nonland card" do
    sentry = ResolvePermanent("Scurrilous Sentry", owner: p1)
    game.settle!
    bears = Card("Grizzly Bears", owner: p1)
    p1.hand.add(bears)
    game.resolve_choice!(card: bears)
    game.settle!

    expect(counters(sentry)).to eq(1)
  end
end
