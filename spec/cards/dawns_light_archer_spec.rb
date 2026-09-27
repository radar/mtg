# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DawnsLightArcher do
  include_context "two player game"

  let!(:archer) { ResolvePermanent("Dawn's Light Archer", owner: p1) }

  it "is a 4/2 elf archer" do
    expect(archer.card.types).to include("Elf", "Archer")
    expect(archer.power).to eq(4)
    expect(archer.toughness).to eq(2)
  end

  it "has flash and reach" do
    expect(archer.card.flash?).to be(true)
    expect(archer.reach?).to be(true)
  end
end
