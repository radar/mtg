# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DeemInferior do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  # The draw step already drew a card this turn, so the spell costs {2}{U} here.
  it "puts the target second from the top of its owner's library" do
    p1.add_mana(blue: 3)
    p1.cast(card: Card("Deem Inferior", owner: p1)) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1).targeting(bears) }
    game.stack.resolve!
    game.resolve_choice!(position: :second)

    expect(p2.library.cards[1]).to eq(bears.card)
    expect(game.battlefield.permanents).not_to include(bears)
  end

  it "puts the target on the bottom of its owner's library" do
    p1.add_mana(blue: 3)
    p1.cast(card: Card("Deem Inferior", owner: p1)) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1).targeting(bears) }
    game.stack.resolve!
    game.resolve_choice!(position: :bottom)

    expect(p2.library.cards.last).to eq(bears.card)
  end

  it "costs {1} less for each card drawn this turn" do
    p1.draw!
    game.settle!
    p1.add_mana(blue: 2)
    p1.cast(card: Card("Deem Inferior", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(bears) }
    game.stack.resolve!
    game.resolve_choice!(position: :bottom)

    expect(p2.library.cards.last).to eq(bears.card)
  end
end
