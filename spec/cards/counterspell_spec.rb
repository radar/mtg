require 'spec_helper'

RSpec.describe Magic::Cards::Counterspell do
  include_context "two player game"

  let(:sol_ring) { Magic::Cards::SolRing.new(game: game, controller: p2)}
  let(:annul) { Magic::Cards::Annul.new(game: game, controller: p1)}
  subject(:counterspell) { described_class.new(game: game, controller: p2) }

  context "counters annul, which was countering sol ring" do
    it "sol ring enters the battlefield" do
      p2.add_mana(red: 1, blue: 2)
      p1.add_mana(blue: 2)
      p2.pay_and_cast!({ generic: { red: 1 } }, sol_ring)
      p1.targeted_pay_and_cast!({ blue: 1 }, annul, targets: [sol_ring])
      p2.targeted_pay_and_cast!({ blue: 2 }, counterspell, targets: [annul])
      game.stack.resolve!
      expect(annul).to be_countered
      expect(annul.zone).to be_graveyard
      expect(sol_ring.zone).to be_battlefield
    end
  end
end
