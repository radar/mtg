require 'spec_helper'

RSpec.describe Magic::Cards::AnointedChorister do
  include_context "two player game"

  let(:card) { Card("Anointed Chorister") }
  subject(:permanent) { Magic::Permanent.resolve(game: game, controller: p1, card: card) }

  before do
    game.battlefield.add(permanent)
  end

  context "triggered ability" do
    it "applies a buff of +3/+3" do
      p1.add_mana(white: 5)

      action = Magic::Actions::ActivateAbility.new(player: p1, permanent: permanent, ability: permanent.activated_abilities.first)
      action.pay_mana({ generic: { white: 4 }, white: 1 })
      action.finalize_costs!(p1)
      game.take_action(action)
      game.tick!

      expect(p1.mana_pool[:white]).to eq(0)
      expect(subject.power).to eq(4)
      expect(subject.toughness).to eq(4)
    end
  end
end
