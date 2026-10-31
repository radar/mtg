# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GothmogMorgulLieutenant do
  include_context "two player game"

  before { go_to_main_phase! }

  def army = p1.creatures.by_type("Army").first

  it "is a legendary 3/3 Human Soldier" do
    gothmog = ResolvePermanent("Gothmog Morgul Lieutenant", owner: p1)

    expect([gothmog.power, gothmog.toughness]).to eq([3, 3])
    expect(gothmog.type?("Human")).to be(true)
    expect(gothmog.type?("Soldier")).to be(true)
    expect(gothmog.legendary?).to be(true)
  end

  it "amasses Orcs 1 when it enters" do
    ResolvePermanent("Gothmog Morgul Lieutenant", owner: p1)
    game.settle!

    expect(army.type?("Orc")).to be(true)
    expect([army.power, army.toughness]).to eq([1, 1])
  end

  it "adds to an existing Army instead of creating another" do
    existing = Magic::Amass.call(source: Card("Grizzly Bears", owner: p1), controller: p1, amount: 2)
    game.settle!
    ResolvePermanent("Gothmog Morgul Lieutenant", owner: p1)
    game.settle!

    expect(p1.creatures.by_type("Army").count).to eq(1)
    expect(existing.power).to eq(3)
    expect(existing.type?("Orc")).to be(true)
  end

  it "gives creature tokens you control deathtouch, including the Army it makes" do
    ResolvePermanent("Gothmog Morgul Lieutenant", owner: p1)
    game.settle!
    game.tick!

    expect(army.deathtouch?).to be(true)
  end

  it "does not give deathtouch to nontoken creatures, itself or opponents' tokens" do
    gothmog = ResolvePermanent("Gothmog Morgul Lieutenant", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    opp_army = Magic::Amass.call(source: bears, controller: p2, amount: 1)
    game.settle!
    game.tick!

    expect(bears.deathtouch?).to be(false)
    expect(gothmog.deathtouch?).to be(false)
    expect(opp_army.deathtouch?).to be(false)
  end

  it "stops granting deathtouch when it leaves the battlefield" do
    gothmog = ResolvePermanent("Gothmog Morgul Lieutenant", owner: p1)
    game.settle!
    game.tick!
    gothmog.destroy!
    game.settle!
    game.tick!

    expect(army.deathtouch?).to be(false)
  end
end
