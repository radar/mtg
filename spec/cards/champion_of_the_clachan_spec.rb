# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChampionOfTheClachan do
  include_context "two player game"

  let(:card) { Card("Champion Of The Clachan", owner: p1) }

  def cast_beholding(payment)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(white: 4)
    p1.cast(card: card) { |a| a.pay_mana(generic: { white: 3 }, white: 1).pay_behold(payment) }
    game.stack.resolve!
    game.tick!
  end

  let(:champion) { p1.creatures.find { _1.card == card } }

  it "is a 4/5 Kithkin Knight with flash" do
    champion = ResolvePermanent("Champion Of The Clachan", owner: p1)
    expect([champion.power, champion.toughness]).to eq([4, 5])
    expect(champion.has_keyword?(:flash)).to eq(true)
  end

  it "exiles a Kithkin you control as it is cast" do
    kithkin = ResolvePermanent("Timid Shieldbearer", owner: p1)
    cast_beholding(kithkin)
    expect(kithkin.card.zone).to be_exile
    expect(card.zone).to be_battlefield
  end

  it "exiles a Kithkin card from your hand as it is cast" do
    kithkin = Card("Timid Shieldbearer", owner: p1)
    p1.hand.add(kithkin)
    cast_beholding(kithkin)
    expect(kithkin.zone).to be_exile
  end

  it "can't have its behold cost paid with mana instead" do
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(white: 6)
    expect { p1.cast(card: card) { |a| a.pay_mana(generic: { white: 3 }, white: 1).pay_behold(generic: { white: 2 }) } }
      .to raise_error(/can't be paid with mana/)
  end

  it "gives other Kithkin you control +1/+1, not itself, non-Kithkin or an opponent's" do
    kithkin = ResolvePermanent("Timid Shieldbearer", owner: p1)
    other = ResolvePermanent("Timid Shieldbearer", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    rival = ResolvePermanent("Timid Shieldbearer", owner: p2)
    cast_beholding(kithkin)

    expect([other.power, other.toughness]).to eq([3, 3])
    expect([champion.power, champion.toughness]).to eq([4, 5])
    expect(bears.power).to eq(2)
    expect(rival.power).to eq(2)
  end

  it "returns the exiled card to its owner's hand when it leaves the battlefield" do
    kithkin = ResolvePermanent("Timid Shieldbearer", owner: p1)
    cast_beholding(kithkin)
    expect(kithkin.card.zone).to be_exile

    champion.destroy!
    game.settle!
    expect(kithkin.card.zone).to be_hand
    expect(p1.hand.cards).to include(kithkin.card)
  end

  it "returns a card from your hand that was exiled too" do
    kithkin = Card("Timid Shieldbearer", owner: p1)
    p1.hand.add(kithkin)
    cast_beholding(kithkin)
    champion.exile!
    game.settle!
    expect(kithkin.zone).to be_hand
  end

  it "leaves nothing behind when the beheld Kithkin was a token" do
    token = ResolvePermanent("Timid Shieldbearer", owner: p1, token: true)
    cast_beholding(token)
    champion.destroy!
    expect { game.settle! }.not_to raise_error
    expect(p1.hand.cards.map(&:name)).not_to include("Timid Shieldbearer")
  end
end
