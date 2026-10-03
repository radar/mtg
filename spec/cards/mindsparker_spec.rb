# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Mindsparker do
  include_context "two player game"

  let!(:mindsparker) { ResolvePermanent("Mindsparker", owner: p1) }

  def cast(player, name, mana, **payment)
    card = Card(name, owner: player)
    player.hand.add(card)
    player.add_mana(**mana)
    player.cast(card:) { |a| a.pay_mana(**payment) }
    game.settle!
  end

  it "is a 3/2 Elemental with first strike" do
    expect([mindsparker.power, mindsparker.toughness]).to eq([3, 2])
    expect(mindsparker).to be_first_strike
  end

  it "deals 2 damage to an opponent who casts a blue instant" do
    cast(p2, "Opt", { blue: 1 }, blue: 1)

    expect(p2.life).to eq(18)
  end

  it "deals 2 damage to an opponent who casts a white instant" do
    cast(p2, "Revitalize", { white: 2 }, generic: { white: 1 }, white: 1)

    expect(p2.life).to eq(21) # -2 from Mindsparker, +3 from Revitalize
  end

  it "ignores a red instant" do
    shock = Card("Shock", owner: p2)
    p2.hand.add(shock)
    p2.add_mana(red: 1)
    p2.cast(card: shock) { |a| a.pay_mana(red: 1).targeting(p1) }
    game.settle!

    expect(p2.life).to eq(20)
  end

  it "ignores a white creature spell" do
    go_to_main_phase_for!(p2)
    cast(p2, "Savannah Lions", { white: 1 }, white: 1)

    expect(p2.life).to eq(20)
  end

  it "ignores your own blue instant" do
    cast(p1, "Opt", { blue: 1 }, blue: 1)

    expect(p1.life).to eq(20)
    expect(p2.life).to eq(20)
  end
end
