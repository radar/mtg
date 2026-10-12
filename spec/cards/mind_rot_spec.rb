# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MindRot do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast(target)
    card = Card("Mind Rot", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 2 }, black: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "makes target player discard two cards" do
    first, second = p2.hand.cards.first(2)
    cast(p2)
    game.resolve_choice!(card: first)
    game.resolve_choice!(card: second)

    expect(p2.hand.count).to eq(5)
    expect([first, second].map(&:zone)).to all(be_graveyard)
  end

  it "can target yourself" do
    cast(p1)

    expect(game.choices.count).to eq(2)
  end
end
