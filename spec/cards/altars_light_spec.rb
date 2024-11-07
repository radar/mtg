require 'spec_helper'

RSpec.describe Magic::Cards::AltarsLight do
  include_context "two player game"
  let(:sol_ring) { Permanent("Sol Ring", game: game, owner: p2) }

  let(:card) { add_to_library("Altars Light", player: p1) }

  before do
    game.next_turn
    add_to_battlefield(sol_ring)
  end

  it "exiles the sol ring" do
    p1.add_mana(white: 4)
    cast_and_resolve(card: card, player: p1) do
      _1.targeting(sol_ring)
    end
    game.stack.resolve!
    expect(sol_ring.card.zone).to be_exile
  end
end
