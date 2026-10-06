require 'spec_helper'

# Rule 514.2: at the start of the cleanup step, damage marked on permanents is removed.
RSpec.describe Magic::Game, "damage at end of turn" do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def go_to_cleanup
    current_turn.untap!
    current_turn.upkeep!
    current_turn.draw!
    current_turn.first_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    current_turn.end!
    current_turn.cleanup!
  end

  it "removes damage marked on a creature that survived" do
    bear.take_damage(1)
    expect(bear.damage).to eq(1)

    go_to_cleanup

    expect(bear.damage).to eq(0)
  end

  it "removes a deathtouch mark from an indestructible creature that survived it" do
    bear.grant_keyword(Magic::Keywords::INDESTRUCTIBLE)
    game.tick!
    bear.mark_for_death!
    expect(bear.lethally_damaged?).to eq(true)

    go_to_cleanup

    expect(bear.lethally_damaged?).to eq(false)
  end

  it "does not kill a creature with damage from an earlier turn that adds up with new damage" do
    bear.take_damage(1)
    go_to_cleanup
    bear.take_damage(1)

    game.check_state_based_actions!

    expect(bear.zone).to eq(game.battlefield)
  end
end
