# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Glimmerburst do
  include_context "two player game"

  let(:glimmerburst) { Card("Glimmerburst", owner: p1) }

  before do
    p1.hand.add(glimmerburst)
    p1.add_mana(blue: 4)
  end

  def cast!
    cast_and_resolve(card: glimmerburst, player: p1) { |a| a.pay_mana(generic: { blue: 3 }, blue: 1) }
  end

  it "draws two cards" do
    expect { cast! }.to change { p1.hand.count }.by(1) # -1 for the spell, +2 drawn
  end

  it "creates a 1/1 white Glimmer enchantment creature token" do
    cast!
    token = p1.creatures.find { _1.type?("Glimmer") }

    expect(token).not_to be_nil
    expect([token.power, token.toughness]).to eq([1, 1])
    expect(token).to be_enchantment
  end

  it "goes to the graveyard" do
    cast!

    expect(glimmerburst.zone).to be_graveyard
  end
end
