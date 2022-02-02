require 'spec_helper'

RSpec.describe Magic::Cards::Annul do
  include_context "two player game"

  let(:sol_ring) { Magic::Cards::SolRing.new(game: game, controller: p2)}
  subject(:annul) { described_class.new(game: game, controller: p1) }

  context "counters a Sol Ring" do
    it "sol ring never enters the battlefield" do
      sol_ring.cast!
      game.stack.targeted_cast(annul, targeting: sol_ring)
      game.stack.resolve!
      expect(annul.zone).to be_graveyard
      expect(sol_ring.zone).to be_graveyard
    end

    it "cannot target a thing that is not an artifact or enchantment" do
      wood_elves = Card("Wood Elves")
      wood_elves.cast!
      expect { game.stack.targeted_cast(annul, targeting: [wood_elves]) }.to raise_error(Magic::Stack::TargetedCast::InvalidTarget)
      game.stack.resolve!
      expect(wood_elves.zone).not_to be_graveyard
    end
  end
end
