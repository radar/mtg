# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KinsbaileAspirant do
  include_context "two player game"

  let(:card) { Card("Kinsbaile Aspirant", owner: p1) }

  before do
    p1.hand.add(card)
    go_to_main_phase!
  end

  def cast_with_behold(payment, mana: { white: 1 })
    p1.add_mana(mana)
    p1.cast(card: card) { |a| a.pay_mana(white: 1).pay_behold(payment) }
    game.stack.resolve!
    game.tick!
  end

  it "is a 2/1 Kithkin Citizen" do
    aspirant = ResolvePermanent("Kinsbaile Aspirant", owner: p1)
    expect([aspirant.power, aspirant.toughness]).to eq([2, 1])
    expect(aspirant.type?("Kithkin")).to eq(true)
  end

  it "can behold a Kithkin you control, which stays where it is" do
    kithkin = ResolvePermanent("Timid Shieldbearer", owner: p1)
    cast_with_behold(kithkin)
    expect(card.zone).to be_battlefield
    expect(kithkin.zone).to be_battlefield
  end

  it "can behold a Kithkin card in your hand, revealing it" do
    kithkin = Card("Timid Shieldbearer", owner: p1)
    p1.hand.add(kithkin)
    cast_with_behold(kithkin)
    expect(card.zone).to be_battlefield
    expect(kithkin.zone).to be_hand
    expect(game.current_turn.events.find { _1.is_a?(Magic::Events::CardsRevealed) }.cards).to eq([kithkin])
  end

  it "can pay {2} instead" do
    cast_with_behold({ generic: { white: 2 } }, mana: { white: 3 })
    expect(card.zone).to be_battlefield
    expect(p1.mana_pool[:white]).to eq(0)
  end

  it "can't behold something that isn't a Kithkin, or a Kithkin you don't have" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    rival = ResolvePermanent("Timid Shieldbearer", owner: p2)
    p1.add_mana(white: 1)
    expect { p1.cast(card: card) { |a| a.pay_mana(white: 1).pay_behold(bears) } }.to raise_error(/can't be beheld/)
    expect { p1.cast(card: card) { |a| a.pay_mana(white: 1).pay_behold(rival) } }.to raise_error(/can't be beheld/)
  end

  it "can't be cast without paying the additional cost" do
    p1.add_mana(white: 1)
    expect { p1.cast(card: card) { |a| a.pay_mana(white: 1) } }.to raise_error(/Additional costs have not been paid/)
  end

  it "gets +1/+1 until end of turn whenever another creature you control enters" do
    aspirant = ResolvePermanent("Kinsbaile Aspirant", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p1)
    expect([aspirant.power, aspirant.toughness]).to eq([3, 2])
    ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Grizzly Bears", owner: p1)
    expect([aspirant.power, aspirant.toughness]).to eq([4, 3])
    aspirant.cleanup!
    expect([aspirant.power, aspirant.toughness]).to eq([2, 1])
  end
end
