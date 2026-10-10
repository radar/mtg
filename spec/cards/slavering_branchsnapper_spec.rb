# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SlaveringBranchsnapper do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 7/6 Lizard with trample" do
    lizard = ResolvePermanent("Slavering Branchsnapper", owner: p1)

    expect([lizard.power, lizard.toughness]).to eq([7, 6])
    expect(lizard).to have_keyword(:trample)
  end

  it "has Forestcycling {2}: discard it to search for a Forest card" do
    card = Card("Slavering Branchsnapper", owner: p1)
    p1.hand.add(card)
    forest = Card("Forest", owner: p1)
    p1.library.add(forest)
    p1.add_mana(green: 2)
    p1.cycle(card:) { _1.pay_mana(generic: { green: 2 }) }

    expect(card.zone).to be_graveyard
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::SearchLibrary)
    choice.resolve!(targets: [forest])

    expect(forest.zone).to be_hand
  end
end
