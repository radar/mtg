# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PridefulParent do
  include_context "two player game"

  let!(:parent) { ResolvePermanent("Prideful Parent", owner: p1) }

  it "is a 2/2 Cat with vigilance" do
    expect([parent.power, parent.toughness]).to eq([2, 2])
    expect(parent).to be_vigilant
  end

  it "creates a 1/1 white Cat creature token when it enters" do
    token = p1.creatures.find { _1.token? }

    expect(token.name).to eq("Cat")
    expect([token.power, token.toughness]).to eq([1, 1])
  end
end
