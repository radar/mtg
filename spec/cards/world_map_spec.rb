require 'spec_helper'

RSpec.describe Magic::Cards::WorldMap do
  include_context "two player game"

  subject { ResolvePermanent("World Map", owner: p1) }

  def p1_library
    9.times.map { Card("Forest") } + [Card("Golgari Guildgate")]
  end

  context "triggered ability" do
    it "searches for a basic land, reveals it" do
      p1.add_mana(green: 1)
      p1.activate_ability(ability: subject.activated_abilities.first) do
        _1.pay_mana(generic: { green: 1 })
      end

      game.stack.resolve!
      choice = game.choices.last
      expect(choice).to be_a(Magic::Cards::WorldMap::BasicLandChoice)
      game.resolve_choice!(target: choice.choices.first)

      forest = p1.hand.by_name("Forest").first
      expect(forest).not_to be_nil
    end

    it "searches for a regular land, reveals it" do
      p1.add_mana(green: 3)
      p1.activate_ability(ability: subject.activated_abilities.last) do
        _1.pay_mana(generic: { green: 3 })
      end

      game.stack.resolve!
      choice = game.choices.last
      expect(choice).to be_a(Magic::Cards::WorldMap::LandChoice)
      expect(choice.choices.map(&:name)).to include("Golgari Guildgate")
      game.resolve_choice!(target: choice.choices.find { _1.name == "Golgari Guildgate" })

      golgari = p1.hand.by_name("Golgari Guildgate").first
      expect(golgari).not_to be_nil
    end
  end
end
