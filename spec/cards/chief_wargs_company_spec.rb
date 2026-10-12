# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChiefWargsCompany do
  include_context "two player game"

  let!(:warg) { ResolvePermanent("Chief Warg's Company", owner: p1) }

  def wolf_tokens = p1.creatures.select { _1.token? && _1.type?("Wolf") }

  it "is a 5/3 Wolf with trample" do
    expect([warg.power, warg.toughness]).to eq([5, 3])
    expect(warg.trample?).to be(true)
  end

  it "creates a 2/2 green Wolf at the beginning of your upkeep" do
    current_turn.untap!
    current_turn.upkeep!
    game.settle!

    expect(wolf_tokens.size).to eq(1)
    expect([wolf_tokens.first.power, wolf_tokens.first.toughness]).to eq([2, 2])
  end

  it "can't attack unless you control two or more other Wolves" do
    expect(warg.can_attack?).to be(false)

    ResolvePermanent("Ambush Wolf", owner: p1)
    expect(warg.can_attack?).to be(false)

    ResolvePermanent("Watchwolf", owner: p1)
    expect(warg.can_attack?).to be(true)
  end
end
