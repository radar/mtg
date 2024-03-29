require 'spec_helper'

RSpec.describe Magic::Game, "combat -- single attacker, weaker blocker" do
  include_context "two player game"

  let!(:odric) { ResolvePermanent("Odric, Lunarch Marshal", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves",owner: p2) }


  context "when in combat" do
    before do
      skip_to_combat!
    end

    let(:combat) { game.combat }

    it "p2 blocks with a wood elves" do
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

      expect(wood_elves).to be_dead

      expect(p2.life).to eq(p2_starting_life)
    end
  end
end
