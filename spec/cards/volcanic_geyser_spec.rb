# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VolcanicGeyser do
  include_context "two player game"

  def cast(target, x:)
    card = Card("Volcanic Geyser", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: x + 2)
    p1.cast(card:, value_for_x: x) { |a| a.pay_mana(x: { red: x }, red: 2).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "deals X damage to a player" do
    cast(p2, x: 4)

    expect(p2.life).to eq(16)
  end

  it "deals X damage to a creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast(bears, x: 2)

    expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
  end

  it "deals no damage with X = 0" do
    cast(p2, x: 0)

    expect(p2.life).to eq(20)
  end
end
