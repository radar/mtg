require 'spec_helper'

RSpec.describe Magic::Cards::Counterspell do
  include_context "two player game"

  let(:sol_ring) { Card("Sol Ring", controller: p2)}
  let(:annul) { Card("Annul", controller: p1)}
  subject(:counterspell) { described_class.new(game: game, controller: p2) }

  context "counters annul, which was countering sol ring" do
    it "sol ring enters the battlefield" do

      game.stack.cast(sol_ring)
      game.stack.targeted_cast(annul, targeting: sol_ring)
      game.stack.targeted_cast(counterspell, targeting: annul)

      game.stack.resolve!
      expect(annul).to be_countered
      expect(annul.zone).to be_graveyard
      expect(sol_ring.zone).to be_battlefield
    end
  end
end
