# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SilvergillMentor do
  include_context "two player game"

  let(:card) { Card("Silvergill Mentor", owner: p1) }

  def cast_with(payment, mana:)
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(mana)
    p1.cast(card: card) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).pay_behold(payment) }
    game.stack.resolve!
    game.settle!
  end

  it "is a 2/1 Merfolk Wizard" do
    mentor = ResolvePermanent("Silvergill Mentor", owner: p1)
    expect([mentor.power, mentor.toughness]).to eq([2, 1])
    expect(mentor.type?("Merfolk")).to eq(true)
  end

  it "creates a 1/1 white and blue Merfolk token when it enters" do
    ResolvePermanent("Silvergill Mentor", owner: p1)
    token = p1.creatures.find(&:token?)
    expect(token.name).to eq("Merfolk")
    expect([token.power, token.toughness]).to eq([1, 1])
    expect(token.colors).to contain_exactly(:white, :blue)
  end

  it "can behold a Merfolk you control, which stays" do
    merfolk = ResolvePermanent("Triton Shorethief", owner: p1)
    cast_with(merfolk, mana: { blue: 2 })
    expect(card.zone).to be_battlefield
    expect(merfolk.zone).to be_battlefield
    expect(p1.creatures.count(&:token?)).to eq(1)
  end

  it "can be cast by paying {2} instead" do
    cast_with({ generic: { blue: 2 } }, mana: { blue: 4 })
    expect(card.zone).to be_battlefield
    expect(p1.mana_pool[:blue]).to eq(0)
  end
end
