require "spec_helper"

RSpec.describe Magic::Game, "action legality -- cycling" do
  include_context "two player game"

  let(:card) { Card("Spark Spray", owner: p1) }

  it "can cycle a card from hand at any time" do
    p1.hand.add(card)
    p1.add_mana(red: 1)

    p1.cycle(card: card) { |a| a.pay_mana(red: 1) }

    expect(card.zone).to be_graveyard
  end

  it "cannot cycle a card that is not in hand" do
    p1.graveyard.add(card)
    p1.add_mana(red: 1)

    expect { p1.cycle(card: card) { |a| a.pay_mana(red: 1) } }
      .to raise_error(Magic::IllegalAction, /not in hand/)
  end
end
