# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Prismabasher do
  include_context "two player game"
  before { go_to_main_phase! }

  it "has trample" do
    expect(ResolvePermanent("Prismabasher", owner: p1).trample?).to eq(true)
  end

  it "gives up to X target creatures you control +X/+X until end of turn" do
    trooper = ResolvePermanent("Alaborn Trooper", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    card = Card("Prismabasher", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 6)
    cast_and_resolve(card: card, player: p1) { |a| a.pay_mana(generic: { green: 4 }, green: 2) }

    trooper_power = trooper.power
    bears_power = bears.power
    game.resolve_choice!(targets: [trooper, bears])
    game.tick!

    # Alaborn Trooper (W) + Grizzly Bears (G) + Prismabasher (G) = 2 colors
    expect(trooper.power).to eq(trooper_power + 2)
    expect(bears.power).to eq(bears_power + 2)
  end
end
