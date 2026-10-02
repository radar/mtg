# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AdamantWill do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "gives target creature +2/+2 and indestructible until end of turn" do
    p1.add_mana(white: 2)
    p1.cast(card: Card("Adamant Will", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect(bears).to be_indestructible
  end

  it "wears off at end of turn" do
    p1.add_mana(white: 2)
    p1.cast(card: Card("Adamant Will", owner: p1)) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(bears) }
    game.stack.resolve!
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([2, 2])
    expect(bears).not_to be_indestructible
  end
end
