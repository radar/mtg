require 'spec_helper'

RSpec.describe Magic::Game, "combat -- pack leader prevents damage to other dogs when attacking" do
  include_context "two player game"

  let!(:lightning_bolt) { Card("Lightning Bolt") }
  let!(:pack_leader) { ResolvePermanent("Pack Leader", controller: p1) }
  let!(:selfless_savior) { ResolvePermanent("Selfless Savior", controller: p1) }
  let!(:vastwood_gorger) { ResolvePermanent("Vastwood Gorger", controller: p2) }

  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "selfless savior has damage prevented by pack leader" do

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        pack_leader,
        target: p2,
      )

      current_turn.declare_attacker(
        selfless_savior,
        target: p2,
      )

      current_turn.attackers_declared!

      current_turn.declare_blocker(
        vastwood_gorger,
        attacker: selfless_savior,
      )

      p2_starting_life = p2.life

      go_to_combat_damage!

      # Pack leader deals 2 damage to P2
      expect(p2.life).to eq(p2_starting_life - 2)
      aggregate_failures do

        expect(pack_leader.zone).to be_battlefield
        pending "Damage should be prevented by Pack Leader's ability -- Selfless savior should not die."
        expect(selfless_savior.zone).to be_battlefield
        expect(p1.graveyard).not_to(include(selfless_savior.card), "Selfless savior should be on the battlefield")
        expect(vastwood_gorger.zone).to be_battlefield
      end
    end

    it "selfless savior does not have Lightning Bolt damage prevented by pack leader" do

      current_turn.declare_attackers!

      current_turn.declare_attacker(
        pack_leader,
        target: p2,
      )

      current_turn.declare_attacker(
        selfless_savior,
        target: p2,
      )

      current_turn.attackers_declared!

      p2.add_mana(red: 1)
      action = cast_action(player: p2, card: lightning_bolt)
      action.pay_mana(red: 1)
      action.targeting(selfless_savior)
      game.take_action(action)
      game.tick!

      current_turn.declare_blocker(
        vastwood_gorger,
        attacker: selfless_savior,
      )

      p2_starting_life = p2.life

      go_to_combat_damage!

      # Pack leader deals 2 damage to P2
      expect(p2.life).to eq(p2_starting_life - 2)
      aggregate_failures do
        expect(pack_leader.zone).to be_battlefield
        # Damage dealt was outside of combat, so savior is dead.
        expect(selfless_savior).to be_dead
        expect(vastwood_gorger.zone).to be_battlefield
      end
    end
  end
end
