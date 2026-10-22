# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StrengthOfTheHarvest do
  include_context "two player game"

  let(:strength) { Card("Strength Of The Harvest", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  before do
    go_to_main_phase!
    p1.hand.items.clear
    p1.hand.add(strength)
  end

  it "is a {2}{G/W} Aura with a land back face" do
    expect(strength.mana_value).to eq(3)
    expect(strength.back_face.name).to eq("Haven of the Harvest")
    expect(strength.back_face).to be_land
  end

  describe "cast as the Aura" do
    def cast_strength
      p1.add_mana(green: 3)
      p1.cast(card: strength) { |a| a.pay_mana(generic: { green: 2 }, green: 1).targeting(bears) }
      game.stack.resolve!
      game.settle!
    end

    it "counts each creature and enchantment you control, including itself" do
      cast_strength

      # Grizzly Bears and the Aura.
      expect([bears.power, bears.toughness]).to eq([4, 4])
    end

    it "counts more creatures you control" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      cast_strength

      expect([bears.power, bears.toughness]).to eq([5, 5])
    end

    it "does not count permanents an opponent controls" do
      ResolvePermanent("Grizzly Bears", owner: p2)
      cast_strength

      expect([bears.power, bears.toughness]).to eq([4, 4])
    end

    it "does not count artifacts or lands" do
      ResolvePermanent("Sol Ring", owner: p1)
      ResolvePermanent("Forest", owner: p1)
      cast_strength

      expect([bears.power, bears.toughness]).to eq([4, 4])
    end
  end

  describe "played as Haven of the Harvest" do
    let(:haven) { p1.permanents.by_name("Haven of the Harvest").first }

    before { p1.play_land(land: strength, face: :back) }

    it "enters tapped" do
      expect(haven).to be_land
      expect(haven).to be_tapped
    end

    it "taps for {G}" do
      haven.untap!
      p1.activate_ability(ability: haven.activated_abilities.first) { _1.choose(:green) }
      expect(p1.mana_pool[:green]).to eq(1)
    end

    it "taps for {W}" do
      haven.untap!
      p1.activate_ability(ability: haven.activated_abilities.first) { _1.choose(:white) }
      expect(p1.mana_pool[:white]).to eq(1)
    end
  end
end
