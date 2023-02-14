require 'spec_helper'

RSpec.describe Magic::Game, "beginning of your end step" do
  include_context "two player game"

  before do
    p1.library.add(Card("Forest"))
  end

  context "with griffin aerie" do
    before do
      ResolvePermanent("Griffin Aerie", owner: p1)
    end

    it "creates 2/2 white griffin creature token with flying" do
      p1.gain_life(3)

      turn = game.current_turn
      turn.untap!
      turn.upkeep!
      turn.draw!
      turn.first_main!
      turn.beginning_of_combat!
      turn.declare_attackers!
      turn.end_of_combat!
      turn.second_main!
      turn.end!

      creatures = game.battlefield.creatures
      expect(creatures.count).to eq(1)
      griffin = creatures.first
      expect(griffin.colors).to eq([:white])
      expect(griffin).to be_flying
      expect(griffin.power).to eq(2)
      expect(griffin.toughness).to eq(2)
    end
  end
end
