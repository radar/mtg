# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DrownerOfTruth do
  include_context "two player game"

  let(:drowner) { Card("Drowner Of Truth", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(drowner)
  end

  def spawns = p1.creatures.select { _1.name == "Eldrazi Spawn" }

  it "is a colorless 7/6 Eldrazi with a land back face" do
    expect(drowner.mana_value).to eq(7)
    expect(drowner.back_face.name).to eq("Drowned Jungle")
    expect(drowner.back_face).to be_land
    permanent = ResolvePermanent("Drowner Of Truth", owner: p1)
    expect([permanent.power, permanent.toughness]).to eq([7, 6])
    expect(permanent.colors).to be_empty
  end

  it "creates two Eldrazi Spawn when colorless mana was spent" do
    p1.add_mana(green: 2, colorless: 5)
    p1.cast(card: drowner) { _1.pay_mana(generic: { colorless: 5 }, green: 2) }
    game.settle!
    game.stack.resolve!
    game.settle!

    expect(spawns.size).to eq(2)
  end

  it "creates the Spawn when the spell is cast, before it resolves" do
    p1.add_mana(green: 2, colorless: 5)
    p1.cast(card: drowner) { _1.pay_mana(generic: { colorless: 5 }, green: 2) }
    game.settle!
    game.stack.resolve!

    expect(spawns.size).to eq(2)
  end

  it "creates no Spawn when only coloured mana was spent" do
    p1.add_mana(green: 7)
    p1.cast(card: drowner) { _1.pay_mana(generic: { green: 5 }, green: 2) }
    game.settle!
    game.stack.resolve!
    game.settle!

    expect(spawns).to be_empty
  end

  describe "played as Drowned Jungle" do
    let(:jungle) { p1.permanents.by_name("Drowned Jungle").first }

    before { p1.play_land(land: drowner, face: :back) }

    it "enters tapped" do
      expect(jungle).to be_land
      expect(jungle).to be_tapped
    end

    it "taps for {G}" do
      jungle.untap!
      p1.activate_ability(ability: jungle.activated_abilities.first) { _1.choose(:green) }
      expect(p1.mana_pool[:green]).to eq(1)
    end

    it "taps for {U}" do
      jungle.untap!
      p1.activate_ability(ability: jungle.activated_abilities.first) { _1.choose(:blue) }
      expect(p1.mana_pool[:blue]).to eq(1)
    end
  end
end
