# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BadDeal do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast
    card = Card("Bad Deal", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 6)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 4 }, black: 2) }
    game.stack.resolve!
    game.settle!
  end

  it "draws you two cards" do
    hand_size = p1.hand.count
    cast

    expect(p1.hand.count).to eq(hand_size + 2) # the spell was added and cast, and two were drawn
  end

  it "makes each opponent discard two cards" do
    first, second = p2.hand.cards.first(2)
    cast
    game.resolve_choice!(cards: [first, second])

    expect([first, second].map(&:zone)).to all(be_graveyard)
  end

  it "makes each player lose 2 life" do
    cast

    expect(p1.life).to eq(18)
    expect(p2.life).to eq(18)
  end
end
