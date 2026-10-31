# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DunlandCrebain do
  include_context "two player game"

  def armies = p1.creatures.select { _1.type?("Army") }

  it "is a 1/1 Bird Horror with flying" do
    crebain = ResolvePermanent("Dunland Crebain", owner: p1)
    expect([crebain.power, crebain.toughness]).to eq([1, 1])
    expect(crebain).to be_flying
    expect(crebain.type?("Bird")).to eq(true)
  end

  it "amasses Orcs 2 on entering, creating a 2/2 black Orc Army" do
    ResolvePermanent("Dunland Crebain", owner: p1)
    expect(armies.count).to eq(1)
    expect(armies.first.type?("Orc")).to eq(true)
    expect([armies.first.power, armies.first.toughness]).to eq([2, 2])
    expect(armies.first.colors).to include(:black)
    expect(p2.creatures.any? { _1.type?("Army") }).to eq(false)
  end

  it "puts two counters on an Army you already control" do
    ResolvePermanent("Dunland Crebain", owner: p1)
    ResolvePermanent("Dunland Crebain", owner: p1)
    expect(armies.count).to eq(1)
    expect(armies.first.power).to eq(4)
  end

  it "makes an existing Goblin Army also an Orc" do
    Magic::Amass.call(source: ResolvePermanent("Ordinary Bear", owner: p1), controller: p1, amount: 1)
    game.settle!
    expect(armies.first.type?("Orc")).to eq(false)
    ResolvePermanent("Dunland Crebain", owner: p1)
    expect(armies.first.type?("Orc")).to eq(true)
    expect(armies.first.power).to eq(3)
  end
end
