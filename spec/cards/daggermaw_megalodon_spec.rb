# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DaggermawMegalodon do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 5/7 Shark with vigilance" do
    shark = ResolvePermanent("Daggermaw Megalodon", owner: p1)

    expect([shark.power, shark.toughness]).to eq([5, 7])
    expect(shark).to have_keyword(:vigilance)
  end

  it "has Islandcycling {2}: discard it to search for an Island card" do
    card = Card("Daggermaw Megalodon", owner: p1)
    p1.hand.add(card)
    island = Card("Island", owner: p1)
    p1.library.add(island)
    p1.add_mana(blue: 2)
    hand = p1.hand.count
    p1.cycle(card:) { _1.pay_mana(generic: { blue: 2 }) }

    expect(card.zone).to be_graveyard
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::SearchLibrary)
    choice.resolve!(targets: [island])

    expect(island.zone).to be_hand
    expect(p1.hand.count).to eq(hand)
  end
end
