# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChartACourse do
  include_context "two player game"

  let(:spell) { Card("Chart A Course", owner: p1) }

  before { p1.hand.add(spell) }

  def cast_spell
    p1.add_mana(blue: 2)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
    game.stack.resolve!
  end

  def attack_then_second_main
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    current_turn.end_of_combat!
    current_turn.second_main!
  end

  it "is a {1}{U} sorcery" do
    expect(spell.cost.cost).to eq(generic: 1, blue: 1)
    expect(spell).to be_a(Magic::Cards::Sorcery)
  end

  it "draws two cards, then makes you discard a card if you didn't attack this turn" do
    go_to_main_phase!
    hand = p1.hand.count
    cast_spell

    expect(p1.hand.count).to eq(hand - 1 + 2)
    expect(game.choices.last).to be_a(Magic::Choice::Discard)

    card = p1.hand.cards.first
    game.resolve_choice!(card:)
    expect(p1.graveyard.cards).to include(card)
    expect(p1.hand.count).to eq(hand - 1 + 2 - 1)
  end

  it "does not make you discard if you attacked this turn" do
    attack_then_second_main
    hand = p1.hand.count
    cast_spell

    expect(p1.hand.count).to eq(hand - 1 + 2)
    expect(game.choices).to be_empty
  end

  it "does not count a creature that didn't attack: attackers must be yours" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    go_to_main_phase!
    game.notify!(Magic::Events::CreatureAttacked.new(attacker: bears, target: p1)) # an opponent's creature "attacking"
    cast_spell

    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end
end
