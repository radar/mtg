require 'spec_helper'

RSpec.describe Magic::Game, "combat -- attacking creature creates attacking token" do
  include_context "two player game"

  let(:falconer_adept) { Card("Falconer Adept", controller: p1) }

  before do
    game.battlefield.add(falconer_adept)
  end

  context "when in combat" do
    before do
      current_turn.go_to_beginning_of_combat!
    end

    it "falconer adept + bird attack p2" do
      expect(game.battlefield.cards).to include(falconer_adept)
      p2_starting_life = p2.life

      expect(current_turn).to be_at_step(:beginning_of_combat)

      expect(current_turn).to be_at_step(:beginning_of_combat)
      current_turn.next_step
      expect(current_turn).to be_at_step(:declare_attackers)

      current_turn.declare_attacker(
        falconer_adept,
        target: p2,
      )

      current_turn.next_step
      bird = current_turn.battlefield.creatures.find { |creature| creature.name == "Bird" }

      expect(bird).not_to be_nil
      current_turn.declare_attacker(
        bird,
        target: p2,
      )

      expect(current_turn).to be_at_step(:declare_blockers)

      current_turn.next_step
      expect(current_turn).to be_at_step(:first_strike)

      current_turn.next_step
      expect(current_turn).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - falconer_adept.power - bird.power)

      current_turn.next_step
      expect(current_turn).to be_at_step(:end_of_combat)
    end
  end
end
