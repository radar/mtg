# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ReefWorm do
  include_context "two player game"

  let!(:worm) { ResolvePermanent("Reef Worm", owner: p1) }

  def token_named(name) = p1.creatures.to_a.detect { |creature| creature.name == name }

  def kill!(permanent)
    permanent.destroy!
    game.settle!
  end

  it "is a 0/1 Worm" do
    expect([worm.power, worm.toughness]).to eq([0, 1])
    expect(worm.type?("Worm")).to be(true)
  end

  it "creates a 3/3 blue Fish when it dies" do
    kill!(worm)

    fish = token_named("Fish")
    expect([fish.power, fish.toughness]).to eq([3, 3])
    expect(fish.card.colors).to eq([:blue])
    expect(token_named("Whale")).to be_nil
  end

  it "creates a 6/6 blue Whale when the Fish dies" do
    kill!(worm)
    kill!(token_named("Fish"))

    whale = token_named("Whale")
    expect([whale.power, whale.toughness]).to eq([6, 6])
    expect(whale.card.colors).to eq([:blue])
    expect(token_named("Fish")).to be_nil
    expect(token_named("Kraken")).to be_nil
  end

  it "creates a 9/9 blue Kraken when the Whale dies" do
    kill!(worm)
    kill!(token_named("Fish"))
    kill!(token_named("Whale"))

    kraken = token_named("Kraken")
    expect([kraken.power, kraken.toughness]).to eq([9, 9])
    expect(kraken.card.colors).to eq([:blue])
    expect(token_named("Whale")).to be_nil
  end

  it "creates nothing more when the Kraken dies" do
    kill!(worm)
    kill!(token_named("Fish"))
    kill!(token_named("Whale"))
    kill!(token_named("Kraken"))

    expect(p1.creatures.to_a).to be_empty
  end
end
