require "spec_helper"

RSpec.describe Magic::Cards::ShipwreckDowser do
  include_context "two player game"

  let(:shipwreck_dowser) { Card("Shipwreck Dowser") }

  before do
    p1.graveyard.add(Card("Shock"))
  end

  it "has prowess" do
    expect(shipwreck_dowser.prowess?).to eq(true)
  end

  it "returns an instant or sorcery from the graveyard" do
    p1.add_mana(blue: 5)

    p1.cast(card: shipwreck_dowser) do
      _1.auto_pay_mana
      _1.targeting(p1.graveyard.first)
    end

    game.stack.resolve!

    expect(p1.hand.by_name("Shock").count).to eq(1)
  end
end
