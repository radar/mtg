require "spec_helper"

RSpec.describe Magic::Cards::BlasphemousAct do
  include_context "two player game"

  it "costs one less for each creature on the battlefield" do
    card = Card("Blasphemous Act", owner: p1)
    3.times { ResolvePermanent("Grizzly Bears", owner: p2) }
    p1.hand.add(card)
    action = p1.prepare_cast(card: card)

    expect(action.mana_cost.cost).to eq(generic: 5, red: 1)
  end
end