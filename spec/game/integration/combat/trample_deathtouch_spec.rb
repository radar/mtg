require 'spec_helper'

RSpec.describe Magic::Game, "combat -- trample with deathtouch" do
  include_context "two player game"

  let!(:colossal_dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  before do
    colossal_dreadmaw.grant_keyword(Magic::Cards::Keywords::DEATHTOUCH)
    skip_to_combat!
  end

  it "only assigns lethal (1) damage to the blocker, tramples the rest through" do
    p2_starting_life = p2.life

    current_turn.declare_attackers!
    current_turn.declare_attacker(colossal_dreadmaw, target: p2)
    current_turn.attackers_declared!
    current_turn.declare_blocker(wood_elves, attacker: colossal_dreadmaw)

    go_to_combat_damage!

    expect(p2.life).to eq(p2_starting_life - 5)
    expect(wood_elves).to be_dead
  end
end
