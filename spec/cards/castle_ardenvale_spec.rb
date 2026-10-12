# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CastleArdenvale do
  include_context "two player game"

  it "enters tapped without a Plains" do
    expect(ResolvePermanent("Castle Ardenvale", owner: p1)).to be_tapped
  end

  it "enters untapped with a Plains" do
    ResolvePermanent("Plains", owner: p1)
    expect(ResolvePermanent("Castle Ardenvale", owner: p1)).to be_untapped
  end

  it "taps for {W}" do
    castle = ResolvePermanent("Castle Ardenvale", owner: p1).tap(&:untap!)
    p1.activate_ability(ability: castle.activated_abilities.first)
    expect(p1.mana_pool[:white]).to eq(1)
  end

  it "makes a 1/1 white Human for {2}{W}{W} and tapping" do
    ResolvePermanent("Plains", owner: p1)
    castle = ResolvePermanent("Castle Ardenvale", owner: p1)
    p1.add_mana(white: 4)

    p1.activate_ability(ability: castle.activated_abilities.last) { |a| a.pay_mana(generic: { white: 2 }, white: 2) }
    game.stack.resolve!

    expect(castle).to be_tapped
    humans = p1.creatures.select { |c| c.name == "Human" && c.token? }
    expect(humans.count).to eq(1)
    expect([humans.first.power, humans.first.toughness]).to eq([1, 1])
  end
end
