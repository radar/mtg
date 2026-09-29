# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KulrathZealot do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 6/5 Elemental Warrior" do
    zealot = ResolvePermanent("Kulrath Zealot", owner: p1)

    expect([zealot.power, zealot.toughness]).to eq([6, 5])
  end

  it "exiles the top card of your library when it enters, playable until the end of your next turn" do
    top = p1.library.first
    ResolvePermanent("Kulrath Zealot", owner: p1)

    expect(top.zone).to be_exile
    expect(game.play_permissions.permits?(top, p1)).to be(true)
  end

  it "has basic landcycling {1}{R}: discard it to search for a basic land card" do
    card = Card("Kulrath Zealot", owner: p1)
    p1.hand.add(card)
    p1.library.add(Card("Forest", owner: p1))
    p1.add_mana(red: 2)
    p1.cycle(card:) { _1.pay_mana(generic: { red: 1 }, red: 1) }

    expect(card.zone).to be_graveyard
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::SearchLibrary)
    forest = p1.library.basic_lands.first
    choice.resolve!(targets: [forest])

    expect(forest.zone).to be_hand
  end

  it "does not draw a card when landcycled" do
    card = Card("Kulrath Zealot", owner: p1)
    p1.hand.add(card)
    hand = p1.hand.count
    p1.add_mana(red: 2)
    p1.cycle(card:) { _1.pay_mana(generic: { red: 1 }, red: 1) }

    expect(p1.hand.count).to eq(hand - 1)
  end
end
