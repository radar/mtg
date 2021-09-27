require 'spec_helper'

RSpec.describe Magic::Cards::Annul do
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(game: game) }
  let(:p2) { Magic::Player.new(game: game) }
  let(:sol_ring) { Magic::Cards::SolRing.new(game: game, controller: p2)}
  subject(:annul) { described_class.new(game: game, controller: p1) }

  context "counters a Sol Ring" do
    it "sol ring never enters the battlefield" do
      sol_ring.cast!
      annul.cast!
      game.stack.resolve!
      game.resolve_effect(Magic::Effects::Destroy, target: sol_ring)
      expect(annul.zone).to be_graveyard
      expect(sol_ring.zone).to be_graveyard
    end
  end
end
