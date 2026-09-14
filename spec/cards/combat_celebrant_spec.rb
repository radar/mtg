# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CombatCelebrant do
  include_context "two player game"

  subject(:combat_celebrant) { ResolvePermanent("Combat Celebrant", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  it "is a 4/1 Human Warrior" do
    expect(combat_celebrant.power).to eq(4)
    expect(combat_celebrant.toughness).to eq(1)
    expect(combat_celebrant.type?("Human")).to be true
    expect(combat_celebrant.type?("Warrior")).to be true
  end

  context "when attacking" do
    before do
      combat_celebrant
      skip_to_combat!
      wood_elves.tap!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: combat_celebrant, target: p2)
      current_turn.attackers_declared!
    end

    it "may be exerted, untapping other creatures and queuing an additional combat phase" do
      game.resolve_choice!

      expect(combat_celebrant.cannot_untap_next_turn).to be true
      expect(wood_elves).not_to be_tapped
      expect(current_turn.additional_combat_pending?).to be true
    end

    it "is not exerted if declined" do
      game.skip_choice!

      expect(combat_celebrant.cannot_untap_next_turn).to be_falsy
      expect(wood_elves).to be_tapped
      expect(current_turn.additional_combat_pending?).to be false
    end

    it "moves back to beginning of combat instead of the second main phase when exerted" do
      game.resolve_choice!

      go_to_combat_damage!
      current_turn.end_of_combat!
      current_turn.second_main!

      expect(current_turn).to be_beginning_of_combat
    end

    it "cannot be exerted again in the additional combat phase this turn" do
      game.resolve_choice!

      go_to_combat_damage!
      current_turn.end_of_combat!
      current_turn.second_main!

      current_turn.declare_attackers!
      p1.declare_attacker(attacker: wood_elves, target: p2)
      current_turn.attackers_declared!

      expect(game.choices).to be_empty
    end
  end
end
