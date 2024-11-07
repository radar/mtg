require 'spec_helper'

RSpec.describe Magic::Cards::GraspOfDarkness do
  include_context "two player game"

  subject { Card("Grasp Of Darkness") }

  context "resolution" do
    let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

    it "applies -4/-4 to Wood Elves" do
      p1.add_mana(black: 2)
      action = cast_action(player: p1, card: subject)
        .pay_mana(black: 2)
        .targeting(wood_elves)
      game.take_action(action)
      game.stack.resolve!
      game.tick!
      expect(wood_elves.power).to eq(-3)
      expect(wood_elves.toughness).to eq(-3)
      expect(wood_elves).to be_dead
      expect(wood_elves.card.zone).to be_graveyard
    end
  end
end
