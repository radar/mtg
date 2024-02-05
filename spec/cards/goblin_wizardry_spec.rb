require 'spec_helper'

RSpec.describe Magic::Cards::GoblinWizardry do
  include_context "two player game"

  subject(:goblin_wizardry) { Card("Goblin Wizardry") }

  context "casting Goblin Wizardry" do
    before do
      p1.add_mana(red: 4)
      p1.cast(card: goblin_wizardry) do
        _1.pay_mana(generic: { red: 3 }, red: 1)
      end
      game.tick!
    end

    def goblin_wizards
      creatures
        .controlled_by(p1)
        .select { |creature| creature.name == "Goblin Wizard" }
    end

    it "summons two Goblin Wizard tokens for p1" do
      expect(goblin_wizards.length).to eq(2)
      expect(goblin_wizards).to all(have_attributes(
        name: "Goblin Wizard",
        power: 1,
        toughness: 1,
        colors: [:red],
      ))
    end

    it "buffs the tokens when a noncreature spell is cast" do
      p1.add_mana(white: 1, blue: 1)
      cast_action = cast_action(player: p1, card: Card("Revitalize"))
        .pay_mana(white: 1, generic: { blue: 1 })
        .perform
      game.tick!
      expect(goblin_wizards).to all(have_attributes(
        name: "Goblin Wizard",
        power: 2,
        toughness: 2,
      ))
    end

    it "has regular power and toughness when a creature is cast" do
      p1.add_mana(red: 2, black: 1)
      cast_action = cast_action(player: p1, card: Card("Onakke Ogre"))
        .pay_mana(red: 1, generic: { red: 1, black: 1 })
        .perform
      game.tick!
      expect(goblin_wizards).to all(have_attributes(
        name: "Goblin Wizard",
        power: 1,
        toughness: 1,
      ))
    end
  end
end
