# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ElementalistAdept do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:adept) { ResolvePermanent("Elementalist Adept", owner: p1) }

  it "is a 2/1 Human Wizard with flash and prowess" do
    expect([adept.power, adept.toughness]).to eq([2, 1])
    expect(adept.card.has_keyword?(:flash)).to eq(true)
    expect(adept.card.has_keyword?(:prowess)).to eq(true)
  end

  it "gets +1/+1 until end of turn when you cast a noncreature spell" do
    p1.add_mana(red: 1)
    p1.cast(card: Card("Boltwave", owner: p1)) { |a| a.pay_mana(red: 1) }
    game.settle!
    game.tick!

    expect([adept.power, adept.toughness]).to eq([3, 2])
  end
end
