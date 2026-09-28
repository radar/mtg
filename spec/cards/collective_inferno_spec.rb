# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CollectiveInferno do
  include_context "two player game"
  before { go_to_main_phase! }

  it "has convoke" do
    expect(Card("Collective Inferno", owner: p1).convoke?).to eq(true)
  end

  context "with Elf chosen" do
    before do
      ResolvePermanent("Collective Inferno", owner: p1)
      game.resolve_choice!(creature_type: "Elf")
    end

    def attack_with(creature)
      current_turn.beginning_of_combat!
      current_turn.declare_attackers!
      p1.declare_attacker(attacker: creature, target: p2)
      current_turn.attackers_declared!
      go_to_combat_damage!
    end

    it "doubles combat damage dealt by a creature you control of the chosen type" do
      elf = ResolvePermanent("Llanowar Elves", owner: p1)
      attack_with(elf)

      expect(p2.life).to eq(18)
    end

    it "does not double damage from other creature types" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      attack_with(bears)

      expect(p2.life).to eq(18)
    end

    it "does not double damage from an opponent's source of the chosen type" do
      theirs = ResolvePermanent("Llanowar Elves", owner: p2)
      theirs.trigger_effect(:deal_damage, damage: 1, target: p1)

      expect(p1.life).to eq(19)
    end

    it "doubles non-combat damage from a source you control of the chosen type" do
      elf = ResolvePermanent("Llanowar Elves", owner: p1)
      elf.trigger_effect(:deal_damage, damage: 1, target: p2)

      expect(p2.life).to eq(18)
    end
  end
end
