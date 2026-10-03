# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HeroicReinforcements do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:card) { Card("Heroic Reinforcements", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opposing) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast
    p1.hand.add(card)
    p1.add_mana(red: 2, white: 2)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 1, white: 1 }, red: 1, white: 1) }
    game.stack.resolve!
    game.tick!
  end

  def soldiers = p1.creatures.select { _1.name == "Soldier" }

  it "creates two 1/1 white Soldier tokens that get +1/+1 and haste" do
    cast

    expect(soldiers.size).to eq(2)
    expect(soldiers.map { [_1.power, _1.toughness] }.uniq).to eq([[2, 2]])
    expect(soldiers).to all(satisfy(&:haste?))
    expect(soldiers.first.colors).to eq([:white])
  end

  it "pumps and gives haste to your existing creatures until end of turn" do
    cast

    expect([bears.power, bears.toughness]).to eq([3, 3])
    expect(bears.haste?).to eq(true)
  end

  it "does not affect the opponent's creatures" do
    cast

    expect([opposing.power, opposing.toughness]).to eq([2, 2])
    expect(opposing.haste?).to eq(false)
  end

  it "wears off at end of turn, leaving 1/1 tokens" do
    cast
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect(soldiers.map(&:power)).to eq([1, 1])
    expect(bears.power).to eq(2)
  end
end
