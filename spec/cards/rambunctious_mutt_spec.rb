require 'spec_helper'

RSpec.describe Magic::Cards::RambunctiousMutt do
  include_context "two player game"

  subject(:rambunctious_mutt) { Card("Rambunctious Mutt", controller: p1) }
  let(:enchantment) { Card("Glorious Anthem", controller: p2) }
  let(:artifact) { Card("Sol Ring", controller: p2) }
  let(:artifact_2) { Card("Sol Ring", controller: p1) }

  context "when rambunctious mutt enters the battlefield" do
    before do
      game.battlefield.add(enchantment)
      game.battlefield.add(artifact)
      game.battlefield.add(artifact_2)
    end

    it "triggers a destroy effect" do
      subject.cast!
      game.stack.resolve!
      effect = game.effects.first

      expect(effect).to be_a(Magic::Effects::SingleTargetAndResolve)
      expect(effect.choices).to match_array([enchantment, artifact])
    end
  end
end
