# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HalanaAndAlenaPartners do
  include_context "two player game"

  let!(:halana) { ResolvePermanent("Halana And Alena, Partners", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1, summoning_sick: true) }

  def counters(permanent) = permanent.counters.of_type(Magic::Counters["+1/+1"]).count

  it "is a 2/3 legendary Human Ranger with reach and first strike" do
    expect([halana.power, halana.toughness]).to eq([2, 3])
    expect(halana).to be_reach
    expect(halana).to be_first_strike
  end

  it "puts X +1/+1 counters on another target creature at the beginning of combat, X being its power, and gives it haste" do
    skip_to_combat!
    game.settle!
    game.tick!

    expect(counters(bears)).to eq(2)
    expect(bears).to be_haste
  end

  it "doesn't put counters on itself" do
    skip_to_combat!
    game.settle!

    expect(counters(halana)).to eq(0)
  end

  it "doesn't trigger at the beginning of an opponent's combat" do
    go_to_main_phase_for!(p2)
    current_turn.beginning_of_combat!
    game.settle!

    expect(counters(bears)).to eq(0)
  end
end
