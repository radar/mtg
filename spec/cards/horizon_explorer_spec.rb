require "spec_helper"

RSpec.describe Magic::Cards::HorizonExplorer do
  include_context "two player game"

  it "makes your lands enter untapped" do
    ResolvePermanent("Horizon Explorer", owner: p1)
    land = ResolvePermanent("Forest", owner: p1, enters_tapped: true)

    expect(land).to be_untapped
  end

  it "creates a Lander when it attacks a player" do
    explorer = ResolvePermanent("Horizon Explorer", owner: p1)
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: explorer, target: p2)
    current_turn.attackers_declared!

    expect(p1.permanents.by_name("Lander").count).to eq(1)
  end
end