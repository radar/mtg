# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShiftingWoodland do
  include_context "two player game"

  before { go_to_main_phase! }

  describe "enters tapped unless you control a Forest" do
    it "enters tapped with no Forest" do
      expect(ResolvePermanent("Shifting Woodland", owner: p1)).to be_tapped
    end

    it "enters untapped with a Forest" do
      ResolvePermanent("Forest", owner: p1)

      expect(ResolvePermanent("Shifting Woodland", owner: p1)).not_to be_tapped
    end
  end

  describe "abilities" do
    let!(:forest) { ResolvePermanent("Forest", owner: p1) }
    let!(:woodland) { ResolvePermanent("Shifting Woodland", owner: p1) }

    it "taps for {G}" do
      p1.activate_ability(ability: woodland.activated_abilities.first)

      expect(p1.mana_pool[:green]).to eq(1)
    end

    context "with fewer than four card types in the graveyard" do
      before { p1.graveyard.add(Card("Grizzly Bears", owner: p1)) }

      it "cannot become a copy" do
        p1.add_mana(green: 4)

        expect do
          p1.activate_ability(ability: woodland.activated_abilities.last) { |a| a.pay_mana(generic: { green: 2 }, green: 2).targeting(p1.graveyard.cards.first) }
        end.to raise_error(Magic::IllegalAction)
      end
    end

    context "with delirium" do
      before do
        ["Grizzly Bears", "Rakdos Signet", "Island", "Shock"].each do |name|
          p1.graveyard.add(Card(name, owner: p1))
        end
      end

      it "becomes a copy of the targeted permanent card until end of turn" do
        bears = p1.graveyard.cards.find { _1.name == "Grizzly Bears" }
        p1.add_mana(green: 4)
        p1.activate_ability(ability: woodland.activated_abilities.last) { |a| a.pay_mana(generic: { green: 2 }, green: 2).targeting(bears) }
        game.stack.resolve!
        game.tick!

        expect(woodland.name).to eq("Grizzly Bears")
        expect(woodland).to be_creature
      end

      it "stops being a copy at end of turn" do
        bears = p1.graveyard.cards.find { _1.name == "Grizzly Bears" }
        p1.add_mana(green: 4)
        p1.activate_ability(ability: woodland.activated_abilities.last) { |a| a.pay_mana(generic: { green: 2 }, green: 2).targeting(bears) }
        game.stack.resolve!
        current_turn.end!
        current_turn.cleanup!

        expect(woodland.name).to eq("Shifting Woodland")
      end
    end
  end
end
