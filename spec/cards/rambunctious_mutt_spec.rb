require 'spec_helper'

RSpec.describe Magic::Cards::RambunctiousMutt do
  include_context "two player game"

  subject(:rambunctious_mutt) { Card("Rambunctious Mutt") }
  let!(:enchantment) { ResolvePermanent("Glorious Anthem", owner: p2) }
  let!(:artifact) { ResolvePermanent("Sol Ring", owner: p1) }
  let!(:artifact_2) { ResolvePermanent("Sol Ring", owner: p2) }

  context "when rambunctious mutt enters the battlefield" do
    it "triggers a destroy effect" do
      cast_and_resolve(card: subject, player: p1)
      choice = game.choices.first

      expect(choice).to be_a(Magic::Choice::DestroyTarget)
      binding.pry
      expect(choice.choices).to match_array([enchantment, artifact_2])
    end
  end
end
