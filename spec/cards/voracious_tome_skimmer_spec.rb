# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VoraciousTomeSkimmer do
  include_context "two player game"

  let!(:skimmer) { ResolvePermanent("Voracious Tome-Skimmer", owner: p1) }

  def cast_bolt_on_opponents_turn
    go_to_main_phase_for!(p2)
    card = Card("Lightning Bolt", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 1)
    p1.cast(card:) { _1.pay_mana(red: 1).targeting(p2) }
    game.settle!
  end

  it "is a 2/3 flyer" do
    expect([skimmer.power, skimmer.toughness]).to eq([2, 3])
    expect(skimmer).to be_flying
  end

  it "can pay 1 life to draw a card when you cast a spell during an opponent's turn" do
    cast_bolt_on_opponents_turn
    hand = p1.hand.count
    life = p1.life
    game.resolve_choice!

    expect(p1.life).to eq(life - 1)
    expect(p1.hand.count).to eq(hand + 1)
  end

  it "does nothing when you decline" do
    cast_bolt_on_opponents_turn
    hand = p1.hand.count
    life = p1.life
    game.skip_choice!

    expect([p1.life, p1.hand.count]).to eq([life, hand])
  end

  it "does not trigger for a spell on your own turn" do
    go_to_main_phase!
    card = Card("Lightning Bolt", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 1)
    p1.cast(card:) { _1.pay_mana(red: 1).targeting(p2) }
    game.settle!

    expect(game.choices).to be_empty
  end

  it "does not trigger for the opponent's spells" do
    go_to_main_phase_for!(p2)
    card = Card("Lightning Bolt", owner: p2)
    p2.hand.add(card)
    p2.add_mana(red: 1)
    p2.cast(card:) { _1.pay_mana(red: 1).targeting(p1) }
    game.settle!

    expect(game.choices).to be_empty
  end
end
