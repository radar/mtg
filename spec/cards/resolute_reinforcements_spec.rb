# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ResoluteReinforcements do
  include_context "two player game"

  let!(:reinforcements) { ResolvePermanent("Resolute Reinforcements", owner: p1) }

  it "is a 1/1 Human Soldier with flash" do
    expect([reinforcements.power, reinforcements.toughness]).to eq([1, 1])
    expect(reinforcements.card.has_keyword?(:flash)).to eq(true)
  end

  it "creates a 1/1 white Soldier creature token when it enters" do
    token = p1.creatures.find { _1.token? }

    expect(token.name).to eq("Soldier")
    expect([token.power, token.toughness]).to eq([1, 1])
  end
end
