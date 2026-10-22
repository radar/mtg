# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WrathOfTheSkies do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }   # mana value 2
  let!(:medallion) { ResolvePermanent("Ruby Medallion", owner: p1) } # artifact, mana value 2
  let!(:diver) { ResolvePermanent("Junk Diver", owner: p2) }      # artifact creature, mana value 3

  before { go_to_main_phase! }

  def cast(x:)
    card = Card("Wrath Of The Skies", owner: p1)
    p1.hand.add(card)
    p1.add_mana(white: x + 2)
    p1.cast(card:, value_for_x: x) { |a| a.pay_mana(x: { white: x }, white: 2) }
    game.stack.resolve!
    game.settle!
  end

  def names = game.battlefield.permanents.map(&:name)

  it "gives you X energy, then offers to pay any amount" do
    cast(x: 3)

    expect(p1.energy).to eq(3)
    expect(game.choices.first).to be_a(Magic::Choice::PayAnyEnergy)
  end

  it "destroys each artifact and creature with mana value at most the energy paid, whoever controls it" do
    cast(x: 3)
    game.resolve_choice!(amount: 2)
    game.settle!

    expect(p1.energy).to eq(1)
    expect(names).not_to include("Grizzly Bears", "Ruby Medallion")
    expect(names).to include("Junk Diver")
  end

  it "destroys a permanent with mana value exactly equal to the energy paid" do
    cast(x: 3)
    game.resolve_choice!(amount: 3)
    game.settle!

    expect(names).not_to include("Junk Diver")
    expect(p1.energy).to eq(0)
  end

  it "destroys enchantments with mana value at most the energy paid" do
    ench = ResolvePermanent("Raid Bombardment", owner: p2) # mana value 3
    cast(x: 3)
    game.resolve_choice!(amount: 3)
    game.settle!

    expect(game.battlefield.permanents).not_to include(ench)
  end

  it "leaves lands and higher mana value permanents alone" do
    land = ResolvePermanent("Island", owner: p2)
    cast(x: 3)
    game.resolve_choice!(amount: 1)
    game.settle!

    expect(game.battlefield.permanents).to include(land, bears, medallion, diver)
    expect(p1.energy).to eq(2)
  end

  it "can't pay more than the energy you have" do
    cast(x: 2)
    game.resolve_choice!(amount: 10)
    game.settle!

    expect(p1.energy).to eq(0)
    expect(names).not_to include("Grizzly Bears")
  end

  it "pays nothing when you decline" do
    cast(x: 3)
    game.skip_choice!
    game.settle!

    expect(p1.energy).to eq(3)
    expect(names).to include("Grizzly Bears", "Ruby Medallion", "Junk Diver")
  end

  it "with X = 0 you get no energy and a paid amount of 0 destroys only mana value 0 permanents (tokens)" do
    ResolvePermanent("Scurry Of Gremlins", owner: p1) # two Gremlin tokens, you get energy for them
    energy = p1.energy
    expect(game.battlefield.permanents.count { _1.name == "Gremlin" }).to eq(2)

    cast(x: 0)
    expect(p1.energy).to eq(energy)
    game.resolve_choice!(amount: 0)
    game.settle!

    expect(names).not_to include("Gremlin")
    expect(names).to include("Grizzly Bears", "Scurry Of Gremlins")
  end
end
