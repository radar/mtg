# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThiefOfExistence do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:thief) { Card("Thief of Existence", owner: p1) }
  let!(:signet) { ResolvePermanent("Arcane Signet", owner: p2) }
  let!(:own_signet) { ResolvePermanent("Arcane Signet", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:forest) { ResolvePermanent("Forest", owner: p2) }

  def cast_thief
    p1.add_mana(colorless: 2, green: 1)
    p1.cast(card: thief) { _1.pay_mana(generic: { colorless: 1 }, colorless: 1, green: 1) }
    game.stack.resolve!
  end

  it "is a devoid 3/4" do
    permanent = ResolvePermanent("Thief of Existence", owner: p1)
    expect(thief.colors).to be_empty
    expect([permanent.power, permanent.toughness]).to eq([3, 4])
  end

  it "exiles a noncreature, nonland permanent an opponent controls with mana value 4 or less when cast" do
    cast_thief
    game.resolve_choice!(target: signet)
    game.stack.resolve!
    game.settle!

    expect(game.exile.cards.map(&:name)).to include("Arcane Signet")
    expect(game.battlefield.permanents).to include(own_signet)
    expect(game.battlefield.permanents).not_to include(signet)
  end

  it "only offers legal targets" do
    cast_thief
    choice = game.choices.first
    expect(choice.choices).to eq([signet])
  end

  it "may exile nothing, in which case leaving draws nothing" do
    cast_thief
    game.skip_choice!
    game.stack.resolve!
    game.settle!
    thief_permanent = p1.creatures.find { _1.name == "Thief of Existence" }
    thief_permanent.destroy!
    game.settle!

    expect(game.choices).to be_empty
    expect(game.exile.cards).to be_empty
  end

  it "makes target opponent draw a card when it leaves the battlefield if it exiled something" do
    cast_thief
    game.resolve_choice!(target: signet)
    game.stack.resolve!
    game.settle!
    thief_permanent = p1.creatures.find { _1.name == "Thief of Existence" }
    hand = p2.hand.cards.count
    thief_permanent.destroy!
    game.settle!
    game.stack.resolve! unless game.stack.empty?
    game.settle!

    expect(p2.hand.cards.count).to eq(hand + 1)
  end

  it "does not offer noncreature nonland permanents with mana value above 4, but offers mana value 4" do
    five = ResolvePermanent("The Arkenstone", owner: p2)
    four = ResolvePermanent("Panharmonicon", owner: p2)
    cast_thief
    choices = game.choices.first.choices
    expect(five.mana_value).to eq(5)
    expect(four.mana_value).to eq(4)
    expect(choices).not_to include(five)
    expect(choices).to include(four)
  end

  it "does not keep the gained ability after leaving and being recast without exiling" do
    cast_thief
    game.resolve_choice!(target: signet)
    game.stack.resolve!
    game.settle!
    p1.creatures.find { _1.name == "Thief of Existence" }.destroy!
    game.settle!
    game.stack.resolve! unless game.stack.empty?
    game.settle!
    expect(thief.opponent_draws_on_leaving).to be(false)
    expect(thief.zone).to eq(p1.graveyard)

    thief.move_to_hand!
    cast_thief
    expect(game.choices).to be_empty
    game.settle!
    hand = p2.hand.cards.count
    p1.creatures.find { _1.name == "Thief of Existence" }.destroy!
    game.settle!
    game.stack.resolve! unless game.stack.empty?
    game.settle!

    expect(p2.hand.cards.count).to eq(hand)
  end

  it "does not trigger the draw when it enters without being cast" do
    permanent = ResolvePermanent("Thief of Existence", owner: p1)
    hand = p2.hand.cards.count
    permanent.destroy!
    game.settle!

    expect(p2.hand.cards.count).to eq(hand)
  end
end
