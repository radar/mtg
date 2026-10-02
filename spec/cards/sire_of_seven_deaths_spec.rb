# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SireOfSevenDeaths do
  include_context "two player game"

  let!(:sire) { ResolvePermanent("Sire Of Seven Deaths", owner: p1) }

  it "is a 7/7 with reach, first strike, vigilance, menace, trample and lifelink" do
    expect([sire.power, sire.toughness]).to eq([7, 7])
    expect(sire).to be_reach
    expect(sire).to be_first_strike
    expect(sire).to be_vigilant
    expect(sire).to be_menace
    expect(sire).to be_trample
    expect(sire).to be_lifelink
  end

  it "has ward—pay 7 life" do
    go_to_main_phase_for!(p2)
    p2.add_mana(red: 1)
    p2.cast(card: Card("Burst Lightning", owner: p2)) { |a| a.pay_mana(red: 1).targeting(sire) }
    game.settle!

    expect(game.choices.last).to be_a(Magic::Choice::Ward)
  end
end
