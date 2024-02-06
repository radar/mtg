require "spec_helper"

RSpec.describe Magic::Cards::ExperimentalOverload do
  include_context "two player game"
  let(:card) { Card("Experimental Overload") }

  before do
    p1.graveyard.add(Card("Shock"))
  end

  it "creates an X/X blue and red Weird creature token, with X being instant/sorceries in GY" do
    p1.add_mana(blue: 3, red: 1)
    p1.cast(card: card) do
      _1.pay_mana(generic: { blue: 2 }, blue: 1, red: 1)
    end

    game.tick!

    weird = creatures.first
    expect(weird.name).to eq("Weird")
    expect(weird.power).to eq(1)
    expect(weird.toughness).to eq(1)
    expect(weird.colors).to eq([:blue, :red])

    choice = game.choices.first
    expect(choice).to be_a(Magic::Choice::SearchGraveyard)

    choice.resolve!(target: p1.graveyard.cards.first)

    shock = p1.hand.by_name("Shock").first
    expect(shock).to be_a(Magic::Cards::Shock)
  end
end
