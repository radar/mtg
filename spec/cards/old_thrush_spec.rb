# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::OldThrush do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_thrush
    card = Card("Old Thrush", owner: p1)
    p1.hand.add(card)
    p1.add_mana(colorless: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { colorless: 2 }) }
    game.stack.resolve!
    game.settle!
    card
  end

  it "is a 1/2 flyer" do
    thrush = ResolvePermanent("Old Thrush", owner: p1)
    expect([thrush.power, thrush.toughness]).to eq([1, 2])
    expect(thrush).to be_flying
  end

  it "gains you 2 life when it enters" do
    cast_thrush
    game.skip_choice! if game.choices.any?

    expect(p1.life).to eq(22)
  end

  it "may put a basic land from your library on top" do
    forest = Card("Forest", owner: p1)
    p1.library.add(forest, 5)
    cast_thrush
    game.resolve_choice!
    game.resolve_choice!(target: forest)

    expect(p1.library.cards.first).to eq(forest)
  end

  it "can decline to search" do
    forest = Card("Forest", owner: p1)
    p1.library.add(forest, 5)
    cast_thrush
    game.skip_choice! while game.choices.any?

    expect(p1.library.cards.first).not_to eq(forest)
  end
end
