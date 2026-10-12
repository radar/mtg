# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OverlordOfTheFloodpits do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Overlord Of The Floodpits", owner: p1).tap { p1.hand.add(_1) } }

  def overlord = p1.permanents.find { _1.card == card }

  it "is a 5/3 flying Avatar Horror enchantment creature" do
    p1.add_mana(blue: 5)
    p1.cast(card: card) { _1.pay_mana(generic: { blue: 3 }, blue: 2) }
    game.stack.resolve!
    game.settle!

    expect([overlord.power, overlord.toughness]).to eq([5, 3])
    expect(overlord).to have_keyword(:flying)
    expect(overlord).to be_creature
  end

  it "draws two cards then discards a card when it enters, even when cast for its impending cost" do
    hand_size = p1.hand.cards.count
    p1.add_mana(blue: 3)
    p1.cast_as(:impending, card: card) { _1.pay_mana(generic: { blue: 1 }, blue: 2) }
    game.stack.resolve!
    game.settle!

    expect(overlord.counters.of_type(Magic::Counters::Time).count).to eq(4)
    expect(game.choices.last).to be_a(Magic::Choice::Discard)
    game.resolve_choice!(card: p1.hand.cards.first)
    expect(p1.hand.cards.count).to eq(hand_size + 2 - 1)
  end

  it "does the same whenever it attacks" do
    ResolvePermanent("Overlord Of The Floodpits", owner: p1)
    game.settle!
    game.skip_choice! while game.choices.any?
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: p1.permanents.find { _1.name == "Overlord of the Floodpits" }, target: p2)
    current_turn.attackers_declared!
    game.settle!

    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end
end
