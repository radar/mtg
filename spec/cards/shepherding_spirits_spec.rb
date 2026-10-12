# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShepherdingSpirits do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 4/5 Spirit with flying" do
    spirit = ResolvePermanent("Shepherding Spirits", owner: p1)

    expect([spirit.power, spirit.toughness]).to eq([4, 5])
    expect(spirit).to have_keyword(:flying)
  end

  it "has Plainscycling {2}: discard it to search for a Plains card" do
    card = Card("Shepherding Spirits", owner: p1)
    p1.hand.add(card)
    plains = Card("Plains", owner: p1)
    p1.library.add(plains)
    p1.add_mana(white: 2)
    p1.cycle(card:) { _1.pay_mana(generic: { white: 2 }) }

    expect(card.zone).to be_graveyard
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::SearchLibrary)
    choice.resolve!(targets: [plains])

    expect(plains.zone).to be_hand
  end
end
