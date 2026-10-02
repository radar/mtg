# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DiveDown do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  it "gives target creature you control +0/+3 and hexproof until end of turn" do
    p1.add_mana(blue: 1)
    p1.cast(card: Card("Dive Down", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 5])
    expect(bears).to be_hexproof
  end

  it "can't target an opponent's creature" do
    p1.add_mana(blue: 1)

    expect { p1.cast(card: Card("Dive Down", owner: p1)) { |a| a.pay_mana(blue: 1).targeting(rival) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
