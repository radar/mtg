require 'spec_helper'

RSpec.describe Magic::Game, "combat -- attacking creature creates attacking token" do
  include_context "two player game"

  let(:falconer_adept) { Card("Falconer Adept", controller: p1) }

  before do
    game.battlefield.add(falconer_adept)
  end

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "falconer adept + bird attack p2" do
      expect(game.battlefield.cards).to include(falconer_adept)
      p2_starting_life = p2.life

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        falconer_adept,
        target: p2,
      )

      current_turn.attackers_declared!
      bird = current_turn.battlefield.creatures.find { |creature| creature.name == "Bird" }
      expect(current_turn).to be_at_step(:declare_attackers)

      expect(bird).not_to be_nil
      current_turn.declare_attacker(
        bird,
        target: p2,
      )

      current_turn.extra_attackers_declared!
      expect(current_turn).to be_at_step(:declare_blockers)

      current_turn.first_strike!
      current_turn.combat_damage!

      expect(p2.life).to eq(p2_starting_life - falconer_adept.power - bird.power)

    end
  end
end
