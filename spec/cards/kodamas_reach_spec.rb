require "spec_helper"

RSpec.describe Magic::Cards::KodamasReach do
  include_context "two player game"
  before { go_to_main_phase! }

  it "adds a library search choice for up to two basic lands" do
    spell = Card("Kodama's Reach", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 3)
    p1.cast(card: spell) { _1.pay_mana(green: 1, generic: { green: 2 }) }
    game.stack.resolve!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::SearchLibrary)
    expect(choice.upto).to eq(2)
    expect(choice.choices).to all(be_basic_land)
  end
end