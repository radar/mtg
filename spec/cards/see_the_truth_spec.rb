# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SeeTheTruth do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast
    card = Card("See The Truth", owner: p1)
    p1.hand.add(card)
    p1.add_mana(blue: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "looks at the top three cards and puts one into your hand and the rest on the bottom" do
    top_three = p1.library.cards.first(3)
    cast
    choice = game.choices.last
    expect(choice.looked_at).to eq(top_three)

    game.resolve_choice!(target: top_three.first)

    expect(top_three.first.zone).to be_hand
    expect(p1.library.last(2)).to match_array(top_three.last(2))
  end

  it "puts all three cards into your hand if it wasn't cast from your hand" do
    top_three = p1.library.cards.first(3)
    card = Card("See The Truth", owner: p1)
    game.exile.add(card)
    game.play_permissions.grant_until_end_of_turn(card:, player: p1)
    p1.add_mana(blue: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1) }
    game.stack.resolve!
    game.settle!

    expect(top_three.map(&:zone)).to all(be_hand)
  end
end
