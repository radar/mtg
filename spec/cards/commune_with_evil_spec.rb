# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CommuneWithEvil do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast
    card = Card("Commune With Evil", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "puts one of the top four cards into your hand and the rest into your graveyard" do
    top_four = p1.library.cards.first(4)
    cast
    game.resolve_choice!(target: top_four.last)

    expect(top_four.last.zone).to be_hand
    expect(top_four.first(3).map(&:zone)).to all(be_graveyard)
  end

  it "gains 3 life" do
    cast

    expect(p1.life).to eq(23)
  end
end
