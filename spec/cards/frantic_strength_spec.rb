# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FranticStrength do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "has flash" do
    expect(Card("Frantic Strength")).to be_flash
  end

  it "gives the enchanted creature +2/+2 and trample" do
    p1.add_mana(green: 3)
    p1.cast(card: Card("Frantic Strength")) do
      _1.auto_pay_mana
      _1.targeting(bears)
    end
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect(bears).to be_trample
  end
end
