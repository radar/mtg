# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FurnaceHellkite do
  include_context "two player game"

  let(:card) { Card("Furnace Hellkite", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.add(card)
  end

  it "is a 5/5 flying artifact Dragon" do
    hellkite = ResolvePermanent("Furnace Hellkite", owner: p1)

    expect([hellkite.power, hellkite.toughness]).to eq([5, 5])
    expect(hellkite).to be_flying
    expect(hellkite).to be_artifact
    expect(hellkite).to be_creature
  end

  it "costs {7} with no artifacts" do
    p1.add_mana(red: 7)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 5 }, red: 2) }
    game.stack.resolve!
    game.settle!

    expect(p1.permanents.map(&:name)).to include("Furnace Hellkite")
  end

  it "costs {1} less for each artifact you control" do
    ResolvePermanent("Sol Ring", owner: p1)
    ResolvePermanent("Sol Ring", owner: p1)
    p1.add_mana(red: 5)
    p1.cast(card:) { |a| a.pay_mana(generic: { red: 3 }, red: 2) }
    game.stack.resolve!
    game.settle!

    expect(p1.permanents.map(&:name)).to include("Furnace Hellkite")
  end

  it "doesn't count opponent's artifacts" do
    ResolvePermanent("Sol Ring", owner: p2)

    expect(card.self_mana_cost_adjustment[:generic].call).to eq(0)
  end

  it "gets +1/+0 for each {R} paid" do
    hellkite = ResolvePermanent("Furnace Hellkite", owner: p1)
    p1.add_mana(red: 2)
    2.times { p1.activate_ability(ability: hellkite.activated_abilities.first) { _1.pay_mana(red: 1) } }
    game.stack.resolve!
    game.stack.resolve!
    game.settle!

    expect([hellkite.power, hellkite.toughness]).to eq([7, 5])
  end
end
