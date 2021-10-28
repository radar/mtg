require 'spec_helper'

RSpec.describe Magic::Cards::Annul do
  include_context "two player game"

  let(:sol_ring) { Magic::Cards::SolRing.new(game: game, controller: p2)}
  subject(:annul) { described_class.new(game: game, controller: p1) }

  context "counters a Sol Ring" do
    it "sol ring never enters the battlefield" do
      sol_ring.cast!
      annul.cast!
      game.stack.resolve!
      expect(annul.zone).to be_graveyard
      expect(sol_ring.zone).to be_graveyard
    end
  end
end
