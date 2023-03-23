require 'spec_helper'

RSpec.describe Magic::Cards::GoblinWizardry do
  include_context "two player game"

  subject(:goblin_wizardry) { described_class.new(game: game) }

  context "Empty Board" do

    before do 
      p1.add_mana(red: 4)
      action = Magic::Actions::Cast.new(player: p1, card: goblin_wizardry)
        .pay_mana(generic: { red: 3 }, red: 1)
      game.take_action(action)
      game.tick!
    end 
   
    it "summons two goblin wizard tokens for p1" do
      expect(game.battlefield.creatures.controlled_by(p1).length).to eq(2)
      expect(game.battlefield.creatures.controlled_by(p2).length).to eq(0)
      first_creature = game.battlefield.creatures.controlled_by(p1).first
      second_creature = game.battlefield.creatures.controlled_by(p1).last
      expect(first_creature.name).to eq("Goblin Wizard")
      expect(first_creature.power).to eq(1)
      expect(first_creature.toughness).to eq(1)
      expect(first_creature.colors).to eq([:red])
      expect(second_creature.name).to eq("Goblin Wizard")
      expect(second_creature.power).to eq(1)
      expect(second_creature.toughness).to eq(1)

    end

    # it "buffs the tokens when a noncreature spell is cast " do
    #   p1.add_mana(white: 1, blue: 1)
    #   action = cast_action(player: p1, card: Card("Revitalize"))
    #     .pay_mana(white: 1, generic: { blue: 1 })
    #     .perform
    #   game.tick!
    #   first_creature = game.battlefield.creatures.controlled_by(p1).first
    #   second_creature = game.battlefield.creatures.controlled_by(p1).last
    #   expect(first_creature.name).to eq("Goblin Wizard")
    #   expect(second_creature.name).to eq("Goblin Wizard")
    #   expect(first_creature.power).to eq(2)
    #   expect(first_creature.toughness).to eq(2)
      

    # end


  end

end
