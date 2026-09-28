# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FlitterwingNuisance do
  include_context "two player game"

  let!(:flitterwing) { ResolvePermanent("Flitterwing Nuisance", owner: p1) }

  it "is a 2/2 flying faerie rogue that enters with a -1/-1 counter" do
    expect(flitterwing.card.types).to include("Faerie", "Rogue")
    expect(flitterwing.power).to eq(1)
    expect(flitterwing.toughness).to eq(1)
    expect(flitterwing.flying?).to be(true)
  end

  it "draws a card whenever a creature you control deals combat damage to a player this turn" do
    p1.add_mana(blue: 3)
    p1.activate_ability(ability: flitterwing.activated_abilities.first) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!

    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: flitterwing, target: p2)
    library_count = p1.library.count
    go_to_combat_damage!

    expect(p1.library.count).to eq(library_count - 1)
  end

  it "does not draw for an opponent's creature dealing damage" do
    p1.add_mana(blue: 3)
    p1.activate_ability(ability: flitterwing.activated_abilities.first) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
    game.next_turn
    library_count = p1.library.count

    go_to_main_phase_for!(p2)
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    skip_to_combat!
    current_turn.declare_attackers!
    p2.declare_attacker(attacker: bears, target: p1)
    go_to_combat_damage!

    expect(p1.library.count).to eq(library_count)
  end
end
