require 'spec_helper'

RSpec.describe Magic::Cards::AltarsLight do
  include_context "two player game"
  let(:sol_ring) { Card("Sol Ring", game: game, controller: p2) }

  let(:card) { described_class.new(game: game, controller: p1) }

  before do
    game.next_turn
    game.battlefield.add(sol_ring)
  end

  it "exiles the sol ring" do
    card.cast!
    game.stack.resolve!
    expect(sol_ring.zone).to be_exile
  end
end
