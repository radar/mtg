require 'spec_helper'

RSpec.describe Magic::Game, "combat -- attacking creature creates attacking token" do
  let(:game) { Magic::Game.new }

  let(:p1) { game.add_player }
  let(:p2) { game.add_player }
  let(:falconer_adept) { Card("Falconer Adept", controller: p1) }

  before do
    game.battlefield.add(falconer_adept)
  end

  context "when in combat" do
    before do
      game.go_to_beginning_of_combat!
    end

    it "falconer adept + bird attack p2" do
      expect(game.battlefield.cards).to include(falconer_adept)
      p2_starting_life = p2.life

      expect(game).to be_at_step(:beginning_of_combat)
      combat = game.combat

      expect(game).to be_at_step(:beginning_of_combat)
      game.next_step
      expect(game).to be_at_step(:declare_attackers)

      combat.declare_attacker(
        falconer_adept,
        target: p2,
      )

      game.next_step
      bird = game.battlefield.creatures.find { |creature| creature.name == "Bird" }

      expect(bird).not_to be_nil
      combat.declare_attacker(
        bird,
        target: p2,
      )

      expect(game).to be_at_step(:declare_blockers)

      game.next_step
      expect(game).to be_at_step(:first_strike)

      game.next_step
      expect(game).to be_at_step(:combat_damage)

      expect(p2.life).to eq(p2_starting_life - falconer_adept.power - bird.power)

      game.next_step
      expect(game).to be_at_step(:end_of_combat)
    end
  end
end
