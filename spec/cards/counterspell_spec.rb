require 'spec_helper'

RSpec.describe Magic::Cards::Counterspell do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:sol_ring) { Magic::Cards::SolRing.new(game: game, controller: p2)}
  let(:annul) { Magic::Cards::Annul.new(game: game, controller: p1)}
  subject(:counterspell) { described_class.new(game: game, controller: p2) }

  context "counters annul, which was countering sol ring" do
    it "sol ring enters the battlefield" do
      sol_ring.cast!
      annul.cast!
      counterspell.cast!
      game.stack.resolve!
      game.resolve_effect(Magic::Effects::CounterSpell, target: annul)
      expect(annul).to be_countered
      expect(game.stack.pending_effects?).to eq(false)
      game.stack.resolve!
      expect(game.stack.pending_effects?).to eq(false)
      expect(annul.zone).to be_graveyard
      expect(sol_ring.zone).to be_battlefield
    end
  end
end
