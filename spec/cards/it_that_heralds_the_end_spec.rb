# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ItThatHeraldsTheEnd do
  include_context "two player game"

  let!(:drone) { ResolvePermanent("It That Heralds The End", owner: p1) }

  it "is a colorless 2/2 Eldrazi Drone" do
    expect([drone.power, drone.toughness]).to eq([2, 2])
    expect(drone.colorless?).to eq(true)
  end

  it "gives other colorless creatures you control +1/+1" do
    spawn = ResolvePermanent("Eldrazi Ravager", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(spawn.power).to eq(spawn.card.base_power + 1)
    expect([bears.power, bears.toughness]).to eq([2, 2])
    expect([drone.power, drone.toughness]).to eq([2, 2])
  end

  it "does not buff an opponent's colorless creatures" do
    theirs = ResolvePermanent("Eldrazi Ravager", owner: p2)
    game.tick!

    expect(theirs.power).to eq(theirs.card.base_power)
  end

  describe "cost reduction" do
    let(:reducer) { Magic::Cards::ItThatHeraldsTheEnd::ReduceBigColorlessCosts.new(source: drone) }

    it "applies to colorless spells with mana value 7 or more you cast" do
      expect(reducer.applies_to?(Card("Ulamog The Defiler", owner: p1))).to eq(true)
      expect(reducer.applies_to?(Card("Ulamog The Defiler", owner: p2))).to eq(false)
    end

    it "does not apply to cheap colorless spells or colored spells" do
      expect(reducer.applies_to?(Card("Eldrazi Ravager", owner: p1))).to eq(false)
      expect(reducer.applies_to?(Card("Grizzly Bears", owner: p1))).to eq(false)
    end
  end
end
