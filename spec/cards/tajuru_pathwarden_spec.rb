# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TajuruPathwarden do
  include_context "two player game"

  it "is a 5/4 with vigilance and trample" do
    pathwarden = ResolvePermanent("Tajuru Pathwarden", owner: p1)

    expect([pathwarden.power, pathwarden.toughness]).to eq([5, 4])
    expect(pathwarden).to be_vigilant
    expect(pathwarden).to be_trample
  end
end
