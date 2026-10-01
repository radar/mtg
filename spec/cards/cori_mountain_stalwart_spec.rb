# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CoriMountainStalwart do
  include_context "two player game"

  let!(:stalwart) { ResolvePermanent("Cori Mountain Stalwart", owner: p1) }

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

  it "is a 3/3" do
    expect([stalwart.power, stalwart.toughness]).to eq([3, 3])
  end

  it "does nothing on the first spell" do
    cast_bolt
    expect([p1.life, p2.life]).to eq([20, 17])
  end

  it "deals 2 damage to each opponent and gains 2 life on the second spell each turn" do
    2.times { cast_bolt }
    expect([p1.life, p2.life]).to eq([22, 12])
  end

  it "does not trigger again on the third spell" do
    3.times { cast_bolt }
    expect([p1.life, p2.life]).to eq([22, 9])
  end
end
