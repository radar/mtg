# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DesolationProwler do
  include_context "two player game"

  let!(:prowler) { ResolvePermanent("Desolation Prowler", owner: p1) }

  def pump
    p1.activate_ability(ability: prowler.activated_abilities.first)
    game.stack.resolve!
    game.tick!
  end

  it "is a 2/2 Wolf" do
    expect([prowler.power, prowler.toughness]).to eq([2, 2])
    expect(prowler.card.types).to include("Wolf")
  end

  it "pays 2 life to get +2/+2 until end of turn" do
    pump

    expect(p1.life).to eq(18)
    expect([prowler.power, prowler.toughness]).to eq([4, 4])
  end

  it "can only be activated once each turn" do
    pump

    expect { pump }.to raise_error(Magic::IllegalAction)
    expect([prowler.power, prowler.toughness]).to eq([4, 4])
  end

  it "wears off at end of turn" do
    pump
    current_turn.end!
    current_turn.cleanup!
    game.tick!

    expect([prowler.power, prowler.toughness]).to eq([2, 2])
  end
end
