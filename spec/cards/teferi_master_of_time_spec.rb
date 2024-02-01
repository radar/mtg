require 'spec_helper'

RSpec.describe Magic::Cards::TeferiMasterOfTime do
  include_context "two player game"

  subject(:planeswalker) { ResolvePermanent("Teferi, Master Of Time") }

  context "+1 ability" do
    let(:ability) { planeswalker.loyalty_abilities.first }

    it "draws, then discards a card" do
      expect(p1).to receive(:draw!)
      p1.activate_loyalty_ability(ability: ability)
      game.tick!
      expect(planeswalker.loyalty).to eq(4)

      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::Discard)
      game.resolve_choice!(card: p1.hand.first)
    end
  end

  context "-3 ability" do
    let(:ability) { planeswalker.loyalty_abilities[1] }
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

    it "target creature you don't control phases out" do
      p1.activate_loyalty_ability(ability: ability) do
        _1.targeting(wood_elves)
      end

      game.tick!

      expect(wood_elves).to be_phased_out
    end
  end

  context "-10 ability" do
    let(:ability) { planeswalker.loyalty_abilities[2] }

    it "take two additional turns" do
      p1.activate_loyalty_ability(ability: ability)

      game.tick!

      expect(game.turns.count).to eq(3)
      # Turn 1 (current turn), Turn 2, and Turn 3
      expect(game.turns.map(&:active_player)).to eq([p1, p1, p1])
    end
  end
end
