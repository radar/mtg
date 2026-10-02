# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SinkholeSurveyor do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) { ResolvePermanent("Sinkhole Surveyor", owner: p1) }

  def attack!
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: permanent, target: p2)
    current_turn.attackers_declared!
  end

  it "has flying" do
    expect(permanent.keywords).to include(Magic::Cards::Keywords::FLYING)
  end

  it "makes you lose 1 life and endure 1 (a counter) when it attacks" do
    attack!
    game.resolve_choice!
    expect(p1.life).to eq(19)
    expect(permanent.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
  end

  it "or creates a 1/1 white Spirit token" do
    attack!
    game.skip_choice!
    expect(p1.life).to eq(19)
    token = p1.permanents.find { _1.name == "Spirit" }
    expect([token.power, token.toughness]).to eq([1, 1])
  end
end
