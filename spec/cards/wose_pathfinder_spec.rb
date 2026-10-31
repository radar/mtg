# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WosePathfinder do
  include_context "two player game"

  let!(:wose) { ResolvePermanent("Wose Pathfinder", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def pump_ability = wose.activated_abilities.find { _1.is_a?(described_class::PumpAbility) }

  def activate_pump(target, mana: { green: 7 })
    p1.add_mana(**mana)
    p1.activate_ability(ability: pump_ability) do |a|
      a.pay_mana(generic: { green: 6 }, green: 1)
      a.targeting(target)
    end
    game.stack.resolve!
    game.tick!
  end

  it "is a 1/1 Human Shaman" do
    expect([wose.power, wose.toughness]).to eq([1, 1])
  end

  it "taps for one mana of any color" do
    ability = wose.activated_abilities.find { _1.is_a?(Magic::TapManaAbility) }
    p1.activate_ability(ability: ability) { |a| a.choose(:blue) }

    expect(p1.mana_pool[:blue]).to eq(1)
    expect(wose).to be_tapped
  end

  it "gives another target creature +3/+3 and trample until end of turn" do
    activate_pump(bears)

    expect([bears.power, bears.toughness]).to eq([5, 5])
    expect(bears).to be_trample
    expect(wose).to be_tapped
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "wears off at end of turn" do
    activate_pump(bears)
    current_turn.end!
    current_turn.cleanup!

    expect([bears.power, bears.toughness]).to eq([2, 2])
    expect(bears).not_to be_trample
  end

  it "can target an opponent's creature but not itself" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)

    expect(pump_ability.target_choices).to contain_exactly(bears, theirs)
  end

  it "cannot target a hexproof creature of an opponent" do
    shark = ResolvePermanent("Spined Megalodon", owner: p2)

    expect { activate_pump(shark) }.to raise_error(RuntimeError, /Invalid target specified/)
    expect(shark.power).to eq(5)
  end

  it "cannot be activated with less than seven mana" do
    expect { activate_pump(bears, mana: { green: 6 }) }.to raise_error(StandardError)
    expect(bears.power).to eq(2)
  end
end
