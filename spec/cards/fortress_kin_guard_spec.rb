# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FortressKinGuard do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) { ResolvePermanent("Fortress Kin-Guard", owner: p1) }

  it "endures 1 on entering: a +1/+1 counter" do
    game.resolve_choice!
    expect(permanent.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(1)
    expect([permanent.power, permanent.toughness]).to eq([2, 3])
  end

  it "or creates a 1/1 white Spirit token" do
    game.skip_choice!
    token = p1.permanents.find { _1.name == "Spirit" }
    expect([token.power, token.toughness]).to eq([1, 1])
  end
end
