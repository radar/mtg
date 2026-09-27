# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VirulentEmissary do
  include_context "two player game"

  let!(:emissary) { ResolvePermanent("Virulent Emissary", owner: p1) }

  it "is a 1/1 elf assassin with deathtouch" do
    expect(emissary.card.types).to include("Elf", "Assassin")
    expect(emissary.power).to eq(1)
    expect(emissary.toughness).to eq(1)
    expect(emissary.deathtouch?).to be(true)
  end

  it "gains its controller 1 life when another creature you control enters" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.settle!

    expect(p1.life).to eq(21)
  end

  it "doesn't trigger for an opponent's creature entering" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    game.settle!

    expect(p1.life).to eq(20)
  end
end
