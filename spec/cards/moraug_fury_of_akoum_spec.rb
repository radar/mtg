require "spec_helper"

RSpec.describe Magic::Cards::MoraugFuryOfAkoum do
  include_context "two player game"

  it "is a legendary creature" do
    expect(ResolvePermanent("Moraug, Fury Of Akoum", owner: p1)).to be_legendary
  end

  it "gets +1/+0 for each time it attacks this turn" do
    moraug = ResolvePermanent("Moraug, Fury Of Akoum", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: moraug, target: p2)
    current_turn.attackers_declared!
    game.tick!

    expect(moraug.power).to eq(7)
  end

  it "queues an additional combat when a land enters during the main phase" do
    moraug = ResolvePermanent("Moraug, Fury Of Akoum", owner: p1)
    go_to_main_phase!
    ResolvePermanent("Forest", owner: p1)

    expect(current_turn).to be_additional_combat_pending
    expect(moraug).to be_creature
  end
end