# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PlazaOfHeroes do
  include_context "two player game"

  subject!(:plaza) { ResolvePermanent("Plaza of Heroes", owner: p1) }

  context "{T}: Add {C}" do
    it "adds one colorless mana" do
      p1.activate_ability(ability: plaza.activated_abilities[0])

      expect(p1.mana_pool[:colorless]).to eq(1)
    end
  end

  context "{T}: Add one mana of any color, to cast a legendary spell" do
    it "adds one mana of the chosen color" do
      p1.activate_ability(ability: plaza.activated_abilities[1]) { |a| a.choose(:white) }

      expect(p1.mana_pool[:white]).to eq(1)
    end
  end

  context "{T}: Add one mana of any color among legendary permanents you control" do
    context "when you control a legendary permanent" do
      let!(:radha) { ResolvePermanent("Radha, Heart of Keld", owner: p1) }

      it "can add mana of one of that permanent's colors" do
        p1.activate_ability(ability: plaza.activated_abilities[2]) { |a| a.choose(:red) }

        expect(p1.mana_pool[:red]).to eq(1)
      end

      it "cannot add mana of a color not among your legendary permanents" do
        expect do
          p1.activate_ability(ability: plaza.activated_abilities[2]) { |a| a.choose(:blue) }
        end.to raise_error(/Invalid choice/)
      end
    end

    context "when you control no legendary permanents" do
      it "cannot produce any mana" do
        expect do
          p1.activate_ability(ability: plaza.activated_abilities[2]) { |a| a.choose(:white) }
        end.to raise_error(/Invalid choice/)
      end
    end
  end

  context "{3}, {T}, Exile this land: target legendary creature gains hexproof and indestructible until end of turn" do
    let!(:radha) { ResolvePermanent("Radha, Heart of Keld", owner: p1) }

    before do
      p1.add_mana(colorless: 3)
      ability = plaza.activated_abilities[3]
      p1.activate_ability(ability: ability) do |a|
        a.pay_mana(generic: { colorless: 3 })
        a.targeting(radha)
      end

      game.stack.resolve!
      game.tick!
    end

    it "grants hexproof and indestructible to the target" do
      expect(radha.hexproof?).to eq(true)
      expect(radha.indestructible?).to eq(true)
    end

    it "exiles the land" do
      expect(game.exile).to include(plaza.card)
      expect(game.battlefield).not_to include(plaza)
    end
  end
end
