# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArbiterOfWoe do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:fodder) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:arbiter) { Card("Arbiter of Woe", owner: p1) }

  def cast_arbiter(sacrificing: fodder)
    p1.hand.add(arbiter)
    p1.add_mana(black: 6)
    p1.cast(card: arbiter) do |a|
      a.pay_mana(generic: { black: 4 }, black: 2)
      a.pay_sacrifice(sacrificing) if sacrificing
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 5/4 flying Demon" do
    cast_arbiter
    permanent = p1.creatures.by_name("Arbiter of Woe").first

    expect([permanent.power, permanent.toughness]).to eq([5, 4])
    expect(permanent).to be_flying
  end

  it "cannot be cast without sacrificing a creature as an additional cost" do
    p1.hand.add(arbiter)
    p1.add_mana(black: 6)

    expect do
      p1.cast(card: arbiter) { |a| a.pay_mana(generic: { black: 4 }, black: 2) }
    end.to raise_error("Additional costs have not been paid")
  end

  it "sacrifices the chosen creature as it is cast" do
    cast_arbiter

    expect(p1.creatures).not_to include(fodder)
    expect(p1.graveyard.cards).to include(fodder.card)
  end

  it "makes each opponent discard a card and lose 2 life, and you draw a card and gain 2 life" do
    opponent_hand = p2.hand.count
    my_hand = p1.hand.count
    cast_arbiter
    game.resolve_choice!(card: p2.hand.first)

    expect(p2.hand.count).to eq(opponent_hand - 1)
    expect(p2.life).to eq(18)
    expect(p1.life).to eq(22)
    # The Arbiter went from hand to stack, and one card was drawn.
    expect(p1.hand.count).to eq(my_hand + 1)
  end
end
