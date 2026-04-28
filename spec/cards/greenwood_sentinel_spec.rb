# frozen_string_literal: true

RSpec.describe Magic::Cards::GreenwoodSentinel do
  include_context "two player game"

  let!(:greenwood_sentinel) { ResolvePermanent("Greenwood Sentinel", owner: p1) }

  it "is an elf scout" do
    expect(greenwood_sentinel.card.types).to include("Elf")
    expect(greenwood_sentinel.card.types).to include("Scout")
    expect(greenwood_sentinel.card.types).to include("Creature")
  end

  it "has vigilance" do
    expect(greenwood_sentinel).to be_vigilant
  end

  it "does not tap when attacking" do
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(greenwood_sentinel, target: p2)
    current_turn.attackers_declared!
    expect(greenwood_sentinel).not_to be_tapped
  end
end
