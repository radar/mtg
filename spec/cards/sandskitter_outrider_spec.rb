# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SandskitterOutrider do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) { ResolvePermanent("Sandskitter Outrider", owner: p1) }

  it "endures 2 on entering: two +1/+1 counters" do
    game.resolve_choice!
    expect(permanent.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(2)
    expect([permanent.power, permanent.toughness]).to eq([4, 3])
  end

  it "or creates a 2/2 white Spirit token" do
    game.skip_choice!
    token = p1.permanents.find { _1.name == "Spirit" }
    expect([token.power, token.toughness]).to eq([2, 2])
  end
end
