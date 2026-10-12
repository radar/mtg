# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FearOfLostTeeth do
  include_context "two player game"

  let!(:fear) { ResolvePermanent("Fear Of Lost Teeth", owner: p1) }

  it "is a 1/1 enchantment creature" do
    expect([fear.power, fear.toughness]).to eq([1, 1])
    expect(fear.type?("Enchantment")).to eq(true)
  end

  it "deals 1 damage to any target and gains 1 life when it dies" do
    fear.destroy!
    game.settle!
    game.resolve_choice!(target: p2)
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(21)
  end
end
