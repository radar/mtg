require 'spec_helper'

RSpec.describe Magic::Cards::AltarsLight do
  include_context "two player game"
  let(:sol_ring) { Permanent("Sol Ring", game: game, controller: p2) }

  let(:card) { add_to_library("Altars Light", player: p1) }

  before do
    game.next_turn
    game.battlefield.add(sol_ring)
  end

  it "exiles the sol ring" do
    action = cast_action(card: card, player: p1)
    action.targeting(sol_ring)
    add_to_stack_and_resolve(action)

    expect(sol_ring.card.zone).to be_exile
  end
end
