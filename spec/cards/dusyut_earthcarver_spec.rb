# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DusyutEarthcarver do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:permanent) { ResolvePermanent("Dusyut Earthcarver", owner: p1) }

  it "has reach" do
    expect(permanent.keywords).to include(Magic::Cards::Keywords::REACH)
  end

  it "endures 3 on entering: three +1/+1 counters" do
    game.resolve_choice!
    expect(permanent.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(3)
  end

  it "or creates a 3/3 white Spirit token" do
    game.skip_choice!
    token = p1.permanents.find { _1.name == "Spirit" }
    expect([token.power, token.toughness]).to eq([3, 3])
    expect(permanent.counters.of_type(Magic::Counters::Plus1Plus1).count).to eq(0)
  end
end
