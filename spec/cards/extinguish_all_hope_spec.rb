require 'spec_helper'

RSpec.describe Magic::Cards::ExtinguishAllHope do
  include_context "two player game"

  subject(:card) { Card("Extinguish All Hope") }

  let(:wood_elves) { ResolvePermanent("Wood Elves") }
  let(:doomwake_giant) { ResolvePermanent("Doomwake Giant") }

  context "when card is cast" do
    before do
      wood_elves
      doomwake_giant
    end

    # Wood Elves = regular creature
    # Doomwake Giant = enchantment creature
    it "destroys the wood elves, keeps doomwake giant" do
      p1.add_mana(black: 6)
      p1.cast(card: card) do
        _1.pay_mana(generic: { black: 4 }, black: 2)
      end

      game.stack.resolve!

      expect(wood_elves.card.zone).to be_graveyard
      expect(doomwake_giant.zone).to be_battlefield
    end
  end
end
