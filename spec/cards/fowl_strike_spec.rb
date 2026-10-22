# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FowlStrike do
  include_context "two player game"

  let!(:strike) { Card("Fowl Strike", owner: p1).tap { |card| p1.hand.add(card) } }
  let!(:flyer) { ResolvePermanent("Mistral Singer", owner: p2) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  describe "the spell" do
    it "destroys target creature with flying" do
      p1.add_mana(green: 2)
      p1.cast(card: strike) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(flyer) }
      game.stack.resolve!
      game.settle!

      expect(p2.permanents).not_to include(flyer)
    end

    it "only targets creatures with flying" do
      expect(strike.target_choices.to_a).to eq([flyer])
    end
  end

  describe "reinforce 2" do
    let(:ability) { strike.hand_abilities.first }

    def reinforce(target)
      p1.add_mana(green: 3)
      p1.activate_ability(ability:) do |action|
        action.targeting(target)
        action.pay_mana(generic: { green: 2 }, green: 1)
      end
      game.stack.resolve!
      game.settle!
    end

    it "discards the card and puts two +1/+1 counters on target creature" do
      reinforce(bears)

      expect(p1.graveyard.cards).to include(strike)
      expect([bears.power, bears.toughness]).to eq([4, 4])
    end

    it "can target any creature" do
      expect(ability.target_choices.to_a).to contain_exactly(flyer, bears)
    end

    it "is only available from hand" do
      p1.hand.remove(strike)
      p1.graveyard.add(strike)

      expect(ability.requirements_met?).to be(false)
    end
  end
end
