# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EasterlingVanguard do
  include_context "two player game"

  let!(:vanguard) { ResolvePermanent("Easterling Vanguard", owner: p1) }

  def armies = p1.creatures.select { _1.type?("Army") }

  it "is a 2/1 Human Warrior" do
    expect([vanguard.power, vanguard.toughness]).to eq([2, 1])
    expect(vanguard.type?("Human")).to eq(true)
    expect(vanguard.type?("Warrior")).to eq(true)
  end

  it "does not amass while it is on the battlefield" do
    expect(armies).to be_empty
  end

  it "amasses Orcs 1 when it dies" do
    vanguard.destroy!
    game.settle!

    expect(armies.count).to eq(1)
    expect(armies.first.type?("Orc")).to eq(true)
    expect([armies.first.power, armies.first.toughness]).to eq([1, 1])
    expect(p2.creatures.any? { _1.type?("Army") }).to eq(false)
  end

  it "puts a counter on an Army you already control" do
    Magic::Amass.call(source: vanguard, controller: p1, amount: 1, subtype: "Orc")
    game.settle!
    vanguard.destroy!
    game.settle!

    expect(armies.count).to eq(1)
    expect(armies.first.power).to eq(2)
  end

  it "gives the Army to the dying creature's controller, not you" do
    other = ResolvePermanent("Easterling Vanguard", owner: p2)
    other.destroy!
    game.settle!

    expect(armies).to be_empty
    expect(p2.creatures.count { _1.type?("Army") }).to eq(1)
  end
end
