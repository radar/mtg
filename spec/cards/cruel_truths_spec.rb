# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CruelTruths do
  include_context "two player game"

  let(:truths) { Card("Cruel Truths", owner: p1) }

  before do
    p1.hand.add(truths)
    p1.add_mana(black: 4)
    p1.cast(card: truths) { |a| a.pay_mana(black: 1, generic: { black: 3 }) }
    game.stack.resolve!
  end

  it "asks to surveil 2 first" do
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(2)
  end

  it "then draws two cards and loses 2 life" do
    hand = p1.hand.count
    game.resolve_choice!(top: p1.library.first(2))

    expect(p1.hand.count).to eq(hand + 2)
    expect(p1.life).to eq(18)
  end

  it "can put surveilled cards into the graveyard" do
    top_two = p1.library.first(2)
    game.resolve_choice!(graveyard: top_two)

    expect(p1.graveyard.cards).to include(*top_two)
  end
end
