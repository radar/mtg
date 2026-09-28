# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SelflessSafewright do
  include_context "two player game"

  it "has flash and convoke" do
    card = Card("Selfless Safewright", owner: p1)
    expect(card.flash?).to eq(true)
    expect(card.convoke?).to eq(true)
  end

  it "gives other permanents you control of the chosen type hexproof and indestructible until end of turn" do
    go_to_main_phase!
    elf = ResolvePermanent("Llanowar Elves", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Llanowar Elves", owner: p2)
    safewright = ResolvePermanent("Selfless Safewright", owner: p1)

    game.resolve_choice!(creature_type: "Elf")
    game.tick!

    expect(elf.hexproof?).to eq(true)
    expect(elf.indestructible?).to eq(true)
    expect(bears.hexproof?).to eq(false)
    expect(theirs.hexproof?).to eq(false)
    expect(safewright.hexproof?).to eq(false)
  end
end
