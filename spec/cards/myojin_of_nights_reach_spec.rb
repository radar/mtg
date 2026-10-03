# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MyojinOfNightsReach do
  include_context "two player game"

  before { go_to_main_phase! }

  def divinity(permanent) = permanent.counters.of_type(Magic::Counters::Divinity).count

  def cast_from_hand
    card = Card("Myojin Of Nights Reach", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 8)
    p1.cast(card:) { |a| a.pay_mana(generic: { black: 5 }, black: 3) }
    game.stack.resolve!
    game.tick!
    p1.creatures.find { _1.card == card }
  end

  def remove_counter(myojin)
    p1.activate_ability(ability: myojin.activated_abilities.first)
    game.stack.resolve!
    game.tick!
  end

  it "is a legendary 5/2 Spirit" do
    myojin = ResolvePermanent("Myojin Of Nights Reach", owner: p1)

    expect([myojin.power, myojin.toughness]).to eq([5, 2])
    expect(myojin).to be_legendary
  end

  it "enters with a divinity counter when cast from your hand" do
    myojin = cast_from_hand

    expect(divinity(myojin)).to eq(1)
  end

  it "enters without a counter when it didn't come from your hand" do
    card = Card("Myojin Of Nights Reach", owner: p1)
    p1.graveyard.add(card)
    myojin = Magic::Permanent.resolve(game:, card:, cast: false)
    game.tick!

    expect(divinity(myojin)).to eq(0)
  end

  it "has indestructible while it has a divinity counter" do
    myojin = cast_from_hand

    expect(myojin).to be_indestructible
    expect(myojin.destroy!).to be(false)
    expect(myojin.zone).to be_battlefield
  end

  it "loses indestructible once the counter is gone" do
    myojin = cast_from_hand
    remove_counter(myojin)

    expect(divinity(myojin)).to eq(0)
    expect(myojin).not_to be_indestructible
  end

  it "isn't indestructible when it entered without a counter" do
    myojin = ResolvePermanent("Myojin Of Nights Reach", owner: p1)

    expect(myojin).not_to be_indestructible
  end

  it "makes each opponent discard their hand when you remove a divinity counter, leaving yours alone" do
    myojin = cast_from_hand
    mine = [*p1.hand.cards]
    theirs = [*p2.hand.cards]
    remove_counter(myojin)

    expect(p2.hand.count).to eq(0)
    expect(p2.graveyard.cards.to_a).to include(*theirs)
    expect([*p1.hand.cards]).to eq(mine)
  end

  it "can't be activated without a divinity counter" do
    myojin = ResolvePermanent("Myojin Of Nights Reach", owner: p1)
    hand = p2.hand.count

    expect { remove_counter(myojin) }.to raise_error(StandardError)
    expect(p2.hand.count).to eq(hand)
  end
end
