require 'spec_helper'

RSpec.describe Magic::Cards::FontOfFertility do
  include_context "two player game"

  subject { ResolvePermanent("Font Of Fertility", controller: p1) }

  context "triggered ability" do
    it "searches for a basic land, puts it on the battlefield tapped" do
      expect(subject.activated_abilities.count).to eq(1)
      p1.add_mana(green: 2)
      action = Magic::Actions::ActivateAbility.new(permanent: subject, ability: subject.activated_abilities.first, player: p1)
      action.pay_mana(green: 1)
      action.pay(p1, :sacrifice)
      game.take_action(action)
      game.stack.resolve!
      expect(subject.zone).to be_graveyard

      forest = game.battlefield.cards.by_name("Forest").first
      expect(forest.zone).to be_battlefield
      expect(forest).to be_tapped
    end
  end
end
