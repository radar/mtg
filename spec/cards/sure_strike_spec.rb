require 'spec_helper'

RSpec.describe Magic::Cards::SureStrike do
  include_context "two player game"

  let!(:sure_strike) { Card("Sure Strike") }
  let!(:onakke_ogre) { ResolvePermanent("Onakke Ogre", owner: p1) }
  context "with a creature in play" do


    it "grants first strike and 3 power" do
      p1.add_mana(red: 2)
      p1.cast(card: sure_strike) do
        _1.pay_mana(generic: { red: 1 }, red: 1).targeting(onakke_ogre)
      end
      game.tick!

      expect(onakke_ogre.power).to eq(7)
      expect(onakke_ogre.toughness).to eq(2)

      game.current_turn.end!
      game.current_turn.cleanup!
      game.next_turn

      expect(onakke_ogre.power).to eq(4)
      expect(onakke_ogre.first_strike?).to eq(false)

    end

  end
end
