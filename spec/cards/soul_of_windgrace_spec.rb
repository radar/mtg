require "spec_helper"

RSpec.describe Magic::Cards::SoulOfWindgrace do
  include_context "two player game"

  it "triggers when it attacks" do
    land = Card("Forest", owner: p1)
    p1.graveyard.add(land)
    soul = ResolvePermanent("Soul of Windgrace", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: soul, target: p2)
    current_turn.attackers_declared!

    expect(game.choices.last.choices).to include(land)
  end
end