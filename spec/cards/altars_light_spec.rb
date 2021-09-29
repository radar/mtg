require 'spec_helper'

RSpec.describe Magic::Cards::AltarsLight do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:sol_ring) { Magic::Cards::SolRing.new(controller: p2) }

  let(:card) { described_class.new(game: game, controller: p1) }

  before do
    game.battlefield.add(sol_ring)
  end

  it "exiles the sol ring" do
    card.cast!
    game.stack.resolve!
    expect(sol_ring.zone).to be_exile
  end
end
