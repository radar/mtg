require "spec_helper"

RSpec.describe Magic::Cards::SpinedMegalodon do
  include_context "two player game"

  let(:permanent) { ResolvePermanent("Spined Megalodon") }

  it "has hexproof" do
    expect(permanent).to be_hexproof
  end

  it "scries 1 when it attacks" do
    skip_to_combat!

    current_turn.declare_attackers!

    p1.declare_attacker(
      attacker: permanent,
      target: p2
    )

    current_turn.attackers_declared!

    expect(game.choices.first).to be_a(Magic::Choice::Scry)
  end
end
