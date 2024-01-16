require 'spec_helper'

RSpec.describe Magic::Cards::Annul do
  include_context "two player game"

  let(:sol_ring) { Card("Sol Ring") }
  subject(:annul) { described_class.new(game: game) }

  before do
    p1.hand.add(annul)
    p2.hand.add(sol_ring)
  end

  context "counters a Sol Ring" do
    it "sol ring never enters the battlefield" do
      p2.add_mana(red: 1)
      action = p2.cast(card: sol_ring) do
        _1.pay_mana(generic: { red: 1 })
      end

      p1.add_mana(blue: 1)
      p1.cast(card: annul) do
        _1.pay_mana(blue: 1)
        _1.targeting(action)
      end

      game.stack.resolve!
      expect(annul.zone).to be_graveyard
      expect(sol_ring.zone).to be_graveyard
    end

    it "cannot target a thing that is not an artifact or enchantment" do
      p2.add_mana(green: 3)
      wood_elves_cast = p2.cast(card: Card("Wood Elves")) do
        _1.pay_mana(generic: { green: 2 }, green: 1)
      end

      p1.add_mana(blue: 1)
      p1.prepare_action(Magic::Actions::Cast, card: annul) do |action|
        expect { action.targeting(wood_elves_cast) }.to raise_error(Magic::Actions::Cast::InvalidTarget)
      end
    end
  end
end
