require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, weaker blocker" do
  include_context "two player game"

  let(:odric) { Card("Odric, Lunarch Marshal") }
  let(:wood_elves) { Card("Wood Elves") }

  before do
    game.battlefield.add(odric)
    game.battlefield.add(wood_elves)
  end

  context "when in combat" do
    before do
      skip_to_combat!
    end

    let(:combat) { game.combat }

    it "p2 blocks with a wood elves" do
      expect(game.battlefield.cards).to include(odric)
      expect(game.battlefield.cards).to include(wood_elves)
      p2_starting_life = p2.life


      current_turn.declare_attackers!

      current_turn.declare_attacker(
        odric,
        target: p2,
      )

      current_turn.attackers_declared!

      current_turn.declare_blocker(
        wood_elves,
        attacker: odric,
      )

      go_to_combat_damage!

      expect(odric.zone).to be_battlefield

      expect(wood_elves.zone).to be_graveyard

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
