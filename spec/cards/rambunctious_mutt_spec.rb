require 'spec_helper'

RSpec.describe Magic::Cards::RambunctiousMutt do
  include_context "two player game"

  subject(:rambunctious_mutt) { Card("Rambunctious Mutt") }
  let!(:enchantment) { ResolvePermanent("Glorious Anthem", owner: p2) }
  let!(:artifact) { ResolvePermanent("Sol Ring", owner: p1) }
  let!(:artifact_2) { ResolvePermanent("Sol Ring", owner: p2) }

  context "when rambunctious mutt enters the battlefield" do
    it "triggers a destroy effect" do
      p1.add_mana(white: 5)
      p1.cast(card: rambunctious_mutt) do
        _1.targeting(enchantment)
        _1.auto_pay_mana
      end

      game.tick!

      expect(enchantment.card.zone).to be_graveyard
    end
  end
end
