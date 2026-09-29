# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlaringCinder do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast_big_spell
    card = Card("Dream Harvest", owner: p1) # mana value 7
    p1.hand.add(card)
    p1.add_mana(blue: 7)
    p1.cast(card:) { _1.pay_mana(generic: { blue: 5 }, blue: 2) }
    game.settle!
  end

  it "is a 3/2 Elemental Sorcerer" do
    cinder = ResolvePermanent("Flaring Cinder", owner: p1)
    game.skip_choice!

    expect([cinder.power, cinder.toughness]).to eq([3, 2])
  end

  it "may discard a card and draw a card when it enters" do
    ResolvePermanent("Flaring Cinder", owner: p1)
    game.resolve_choice!
    card = p1.hand.cards.first
    hand = p1.hand.count
    game.resolve_choice!(card:)

    expect(card.zone).to be_graveyard
    expect(p1.hand.count).to eq(hand) # discarded one, drew one
  end

  it "does nothing when you decline" do
    ResolvePermanent("Flaring Cinder", owner: p1)
    hand = p1.hand.count
    game.skip_choice!

    expect(p1.hand.count).to eq(hand)
  end

  it "does the same whenever you cast a spell with mana value 4 or greater" do
    ResolvePermanent("Flaring Cinder", owner: p1)
    game.skip_choice!
    cast_big_spell

    expect(game.choices.last).to be_a(described_class::MayDiscardChoice)
  end

  it "ignores cheaper spells and the opponent's spells" do
    ResolvePermanent("Flaring Cinder", owner: p1)
    game.skip_choice!
    card = Card("Grizzly Bears", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 2)
    p1.cast(card:) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!

    expect(game.choices).to be_empty
  end
end
