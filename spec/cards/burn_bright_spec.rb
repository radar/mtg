require 'spec_helper'

RSpec.describe Magic::Cards::BurnBright do
  include_context "two player game"

  let!(:burn_bright) { described_class.new(game: game) }
  let!(:blood_glutton) { ResolvePermanent("Blood Glutton", owner: p1) }
  let!(:onakke_ogre) { ResolvePermanent("Onakke Ogre", owner: p1) }

  context "with 2 creature in play" do
    
    it "grants 2 power to both creatures " do
      expect(onakke_ogre.power).to eq(4)
      p1.add_mana(red: 3)
      action = Magic::Actions::Cast.new(player: p1, card: burn_bright)
        .pay_mana(generic: { red: 2 }, red: 1)
      game.take_action(action)
      game.tick!

      expect(onakke_ogre.power).to eq(6)
      expect(onakke_ogre.toughness).to eq(2)

      # game.current_turn.end!
      # game.current_turn.cleanup!
      # game.next_turn

      # expect(onakke_ogre.power).to eq(4)
      # expect(onakke_ogre.first_strike?).to eq(false)

    end

  end
end
