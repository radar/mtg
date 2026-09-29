# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BrigidClachansHeart do
  include_context "two player game"
  before { go_to_main_phase! }

  let(:brigid) { ResolvePermanent("Brigid, Clachan's Heart", owner: p1) }

  def kithkin = p1.creatures.select { _1.name == "Kithkin" }

  def first_main_phase!
    game.notify!(Magic::Events::FirstMainPhase.new(active_player: p1))
    game.settle!
  end

  it "is a 3/2 legendary Kithkin Warrior" do
    expect([brigid.power, brigid.toughness]).to eq([3, 2])
    expect(brigid).to be_legendary
    expect(brigid.type?("Warrior")).to be(true)
  end

  it "creates a 1/1 green and white Kithkin token when it enters" do
    brigid

    expect(kithkin.size).to eq(1)
    expect([kithkin.first.power, kithkin.first.toughness]).to eq([1, 1])
    expect(kithkin.first.colors).to contain_exactly(:green, :white)
  end

  it "creates another token each time it transforms into this face" do
    brigid
    brigid.transform!
    brigid.transform!
    game.settle!

    expect(kithkin.size).to eq(2)
  end

  describe "transforming" do
    before { brigid }

    it "may pay {G} at the beginning of your first main phase to transform" do
      p1.add_mana(green: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)

      expect(brigid.transformed?).to be(true)
      expect(brigid.name).to eq("Brigid, Doun's Mind")
      expect(brigid.colors).to eq([:green])
      expect(brigid.mana_value).to eq(3)
      expect([brigid.power, brigid.toughness]).to eq([3, 2])
      expect(brigid.type?("Soldier")).to be(true)
    end

    it "does not create a token when transforming into the back face" do
      brigid.transform!
      game.settle!

      expect(kithkin.size).to eq(1)
    end
  end

  describe "Brigid, Doun's Mind" do
    before do
      brigid
      brigid.transform!
      game.settle!
    end

    it "taps for X green mana, where X is the number of other creatures you control" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      ResolvePermanent("Grizzly Bears", owner: p2) # not counted
      ability = brigid.activated_abilities.first
      p1.activate_ability(ability:) { _1.choose(:green) }

      expect(p1.mana_pool[:green]).to eq(2) # the Kithkin token and the Bears
    end

    it "taps for white mana instead when chosen" do
      ability = brigid.activated_abilities.first
      p1.activate_ability(ability:) { _1.choose(:white) }

      expect(p1.mana_pool[:white]).to eq(1)
    end

    it "may pay {W} to transform back" do
      p1.add_mana(white: 1)
      first_main_phase!
      game.resolve_choice!(payment: nil)
      game.settle!

      expect(brigid.transformed?).to be(false)
      expect(kithkin.size).to eq(2)
    end
  end
end
