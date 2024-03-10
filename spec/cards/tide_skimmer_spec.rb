require "spec_helper"

RSpec.describe Magic::Cards::TideSkimmer do
  include_context "two player game"

  let!(:tide_skimmer) { ResolvePermanent("Tide Skimmer") }

  before do
    skip_to_combat!
  end

  it "does not draw a card" do
    expect(p1).not_to receive(:draw!)

    current_turn.declare_attackers!

    p1.declare_attacker(
      attacker: tide_skimmer,
      target: p2
    )

    current_turn.attackers_declared!
  end

  context "when there's another flying creature" do
    let!(:concordia_pegasus) { ResolvePermanent("Concordia Pegasus") }

    it "draws a card" do
      expect(p1).to receive(:draw!).once
      current_turn.declare_attackers!

      p1.declare_attacker(
        attacker: tide_skimmer,
        target: p2
      )

      p1.declare_attacker(
        attacker: concordia_pegasus,
        target: p2
      )

      current_turn.attackers_declared!
    end
  end
end
