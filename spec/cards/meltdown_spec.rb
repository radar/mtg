# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Meltdown do
  include_context "two player game"

  let(:card) { Card("Meltdown", owner: p1) }

  before { go_to_main_phase! }

  def cast(x:)
    p1.hand.add(card)
    p1.add_mana(red: x + 1)
    p1.cast(card:, value_for_x: x) { |a| a.pay_mana(x: { red: x }, red: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "destroys each artifact with mana value X or less, whoever controls it" do
    cheap = ResolvePermanent("Ruby Medallion", owner: p1)
    theirs = ResolvePermanent("Jet Medallion", owner: p2)
    cast(x: 2)
    expect(battlefield.permanents).not_to include(cheap)
    expect(battlefield.permanents).not_to include(theirs)
  end

  it "leaves artifacts with mana value greater than X" do
    diver = ResolvePermanent("Junk Diver", owner: p2)
    medallion = ResolvePermanent("Ruby Medallion", owner: p1)
    cast(x: 2)
    expect(battlefield.permanents).to include(diver)
    expect(battlefield.permanents).not_to include(medallion)
  end

  it "destroys an artifact with mana value exactly X" do
    diver = ResolvePermanent("Junk Diver", owner: p2)
    cast(x: 3)
    expect(battlefield.permanents).not_to include(diver)
  end

  it "leaves nonartifact permanents" do
    bear = ResolvePermanent("Grizzly Bears", owner: p1)
    cast(x: 5)
    expect(battlefield.permanents).to include(bear)
  end

  def battlefield = game.battlefield
end
