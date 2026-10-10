# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GiveInToViolence do
  include_context "two player game"

  it "gives target creature +2/+2 and lifelink until end of turn" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    card = Card("Give In To Violence", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 2)
    p1.cast(card: card) do |action|
      action.targeting(bears)
      action.pay_mana(generic: { black: 1 }, black: 1)
    end
    game.stack.resolve!
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 4])
    expect(bears).to be_lifelink
  end
end
