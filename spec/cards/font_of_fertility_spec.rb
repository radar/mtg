require 'spec_helper'

RSpec.describe Magic::Cards::FontOfFertility do
  include_context "two player game"

  subject { ResolvePermanent("Font Of Fertility", owner: p1) }

  def p1_library
    9.times.map { Card("Forest") }
  end

  context "triggered ability" do
    it "searches for a basic land, puts it on the battlefield tapped" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(green: 2)
      p1.activate_ability(ability: subject.activated_abilities.first) do
        _1
          .pay_mana(green: 1)
      end

      game.stack.resolve!
      choice = game.choices.last
      expect(choice).to be_a(Magic::Cards::FontOfFertility::Choice)
      game.resolve_choice!(target: choice.choices.first)
      expect(subject.zone).to be_nil
      expect(p1.graveyard.by_name(subject.name).count).to eq(1)

      forest = game.battlefield.cards.by_name("Forest").first
      expect(forest.zone).to be_battlefield
      expect(forest).to be_tapped
    end
  end
end
