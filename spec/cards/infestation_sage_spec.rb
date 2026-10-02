# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InfestationSage do
  include_context "two player game"

  let!(:sage) { ResolvePermanent("Infestation Sage", owner: p1) }

  it "is a 1/1 Elf Warlock" do
    expect([sage.power, sage.toughness]).to eq([1, 1])
  end

  it "creates a 1/1 black and green Insect token with flying when it dies" do
    sage.destroy!
    game.settle!
    insect = p1.creatures.find { _1.name == "Insect" }

    expect([insect.power, insect.toughness]).to eq([1, 1])
    expect(insect).to be_flying
  end
end
