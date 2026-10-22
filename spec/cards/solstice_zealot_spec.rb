# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SolsticeZealot do
  include_context "two player game"

  let!(:zealot) { ResolvePermanent("Solstice Zealot", owner: p1) }
  let!(:victim) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def activate(target)
    p1.activate_ability(ability: zealot.activated_abilities.first) { |action| action.targeting(target) }
    game.stack.resolve!
  end

  it "is a 2/3 Rhino Cleric" do
    expect([zealot.power, zealot.toughness]).to eq([2, 3])
    expect(zealot.types.map(&:to_s)).to include("Rhino", "Cleric")
  end

  it "gives you two energy when it enters" do
    expect(p1.energy).to eq(2)
  end

  it "taps, paying {E}, to tap target creature" do
    activate(victim)

    expect(victim).to be_tapped
    expect(zealot).to be_tapped
    expect(p1.energy).to eq(1)
  end

  it "can target your own creatures" do
    mine = ResolvePermanent("Grizzly Bears", owner: p1)
    expect(zealot.activated_abilities.first.target_choices).to include(mine, victim)
  end

  it "can't be activated without energy" do
    p1.pay_energy!(2)

    expect { activate(victim) }.to raise_error(StandardError)
    expect(victim).not_to be_tapped
  end

  it "can't be activated while tapped" do
    zealot.tap!

    expect { activate(victim) }.to raise_error(StandardError)
    expect(p1.energy).to eq(2)
  end
end
