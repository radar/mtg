# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WingbladeDisciple do
  include_context "two player game"

  let!(:disciple) { ResolvePermanent("Wingblade Disciple", owner: p1) }

  before do
    go_to_main_phase!
    p1.add_mana(red: 4)
  end

  def cast_bolt
    card = Card("Lightning Bolt")
    p1.hand.add(card)
    p1.cast(card:) do |action|
      action.pay_mana(red: 1)
      action.targeting(p2)
    end
    game.stack.resolve!
    game.settle!
  end

  def birds = p1.creatures.select { _1.name == "Bird" }

  it "is a 2/2 flyer" do
    expect([disciple.power, disciple.toughness]).to eq([2, 2])
    expect(disciple).to have_keyword(Magic::Cards::Keywords::FLYING)
  end

  it "creates a 1/1 white flying Bird on the second spell each turn only" do
    cast_bolt
    expect(birds).to be_empty
    cast_bolt
    expect(birds.size).to eq(1)
    expect([birds.first.power, birds.first.toughness, birds.first.colors]).to eq([1, 1, [:white]])
    expect(birds.first).to have_keyword(Magic::Cards::Keywords::FLYING)
    cast_bolt
    expect(birds.size).to eq(1)
  end
end
