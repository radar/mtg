# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThreeTreeCity do
  include_context "two player game"

  let!(:city) { ResolvePermanent("Three Tree City", owner: p1) }

  it "is a legendary land" do
    expect(city.card.types).to include("Legendary")
    expect(city.card.types).to include("Land")
  end

  context "when entering the battlefield" do
    it "presents a choice to choose a creature type" do
      expect(game.choices.last).to be_a(described_class::CreatureTypeChoice)
    end
  end

  describe "colorless mana ability" do
    it "adds {C}" do
      game.resolve_choice!(creature_type: "Elf")
      p1.activate_ability(ability: city.activated_abilities.first)
      expect(p1.mana_pool[:colorless]).to eq(1)
    end
  end

  describe "chosen color ability" do
    before do
      game.resolve_choice!(creature_type: "Elf")
      ResolvePermanent("Elvish Mystic", owner: p1)
      ResolvePermanent("Elvish Mystic", owner: p1)
      ResolvePermanent("Grizzly Bears", owner: p1)
    end

    it "adds mana of the chosen color equal to the number of creatures you control of the chosen type" do
      p1.add_mana(green: 2)
      p1.activate_ability(ability: city.activated_abilities.last) do |a|
        a.pay_mana(generic: { green: 2 })
        a.choose(:blue)
      end

      expect(p1.mana_pool[:blue]).to eq(2)
    end
  end
end
