# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RoadsGoEverEverOn do
  include_context "two player game"

  let(:card) { Card("Roads Go Ever, Ever On", owner: p1) }
  let!(:plains_one) { Card("Plains", owner: p1) }
  let!(:plains_two) { Card("Plains", owner: p1) }

  def saga = p1.permanents.find { _1.name == "Roads Go Ever, Ever On" }

  def next_chapter
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  before do
    p1.library.add(plains_one)
    p1.library.add(plains_two)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(white: 2)
    p1.cast(card:) { _1.pay_mana(generic: { white: 1 }, white: 1) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "I — exiles up to two basic Plains from the library and gains 2 life" do
    expect(p1.life).to eq(22)
    game.resolve_choice!(targets: [plains_one, plains_two])

    expect(plains_one.zone).to be_exile
    expect(plains_two.zone).to be_exile
    expect(saga.exiled_cards).to contain_exactly(plains_one, plains_two)
  end

  it "II and III — put a card exiled with the Saga into its owner's hand" do
    game.resolve_choice!(targets: [plains_one, plains_two])

    next_chapter
    game.resolve_choice!(target: plains_one) if game.choices.any?
    expect(plains_one.zone).to be_hand

    next_chapter
    game.resolve_choice!(target: plains_two) if game.choices.any?
    expect(plains_two.zone).to be_hand
  end

  it "IV — whenever you attack this turn, target creature you control gets +1/+1 for each Plains you control" do
    game.resolve_choice!(targets: [plains_one, plains_two])
    next_chapter
    game.resolve_choice!(target: plains_one)
    next_chapter # only one card left, so no choice is needed
    ResolvePermanent("Plains", owner: p1)
    ResolvePermanent("Plains", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    next_chapter
    expect(p1.graveyard.cards.map(&:name)).to include("Roads Go Ever, Ever On")

    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(bears, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
  end
end
