require "spec_helper"

RSpec.describe Magic::Cards::WarrenTorchmaster do
  include_context "two player game"

  let!(:torchmaster) { ResolvePermanent("Warren Torchmaster", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true) }

  def minus_counters(permanent) = permanent.counters.of_type(Magic::Counters::Minus1Minus1).count

  it "is a 2/2" do
    expect([torchmaster.power, torchmaster.toughness]).to eq([2, 2])
  end

  it "may blight 1 at the beginning of combat on your turn; when you do, a creature gains haste" do
    skip_to_combat!
    game.resolve_choice!
    game.resolve_choice!(target: torchmaster)
    expect(minus_counters(torchmaster)).to eq(1)

    game.resolve_choice!(target: bears)
    game.tick!
    expect(bears).to be_haste
  end

  it "grants nothing when you decline" do
    skip_to_combat!
    game.skip_choice!
    game.tick!

    expect(bears).not_to be_haste
    expect(minus_counters(torchmaster)).to eq(0)
  end

  it "doesn't trigger at the beginning of the opponent's combat" do
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!

    expect(game.choices).to be_empty
  end
end
