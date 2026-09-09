require "spec_helper"

RSpec.describe Magic::Cards::Harrow do
  include_context "two player game"

  it "requires sacrificing a land as an additional cost" do
    land = ResolvePermanent("Forest", owner: p1)
    card = Card("Harrow", owner: p1)
    p1.hand.add(card)
    p1.add_mana(green: 3)
    p1.cast(card: card) do |action|
      action.pay_mana(green: 1, generic: { green: 2 })
      action.pay_sacrifice(land)
    end

    expect(land.card.zone).to be_graveyard
  end
end