# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheNotaryHobbits do
  include_context "two player game"

  def hobbits = p1.creatures.select { _1.name == "The Notary Hobbits" }

  it "creates two nonlegendary token copies when it enters" do
    original = ResolvePermanent("The Notary Hobbits", owner: p1)
    game.settle!

    expect(hobbits.count).to eq(3)
    tokens = hobbits.select(&:token?)
    expect(tokens.count).to eq(2)
    expect(tokens.none?(&:legendary?)).to eq(true)
    expect(original).to be_legendary
  end

  it "does not copy again when a token copy enters" do
    ResolvePermanent("The Notary Hobbits", owner: p1)
    game.settle!

    expect(hobbits.count).to eq(3)
  end

  it "taps for {C} for each Halfling you control" do
    original = ResolvePermanent("The Notary Hobbits", owner: p1)
    game.settle!
    original.untap!
    p1.activate_ability(ability: original.activated_abilities.first)

    expect(p1.mana_pool[:colorless]).to eq(3)
  end
end
