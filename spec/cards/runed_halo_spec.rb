require 'spec_helper'

RSpec.describe Magic::Cards::RunedHalo do
  include_context "two player game"
  subject { Card("Runed Halo", controller: p1) }
  let(:wood_elves) { Card("Wood Elves", controller: p2) }

  context "when runed halo enters the battlefield" do

    it "triggers a 'choose a card' effect" do
      subject.cast!
      game.stack.resolve!
      effect = game.effects.first
      expect(effect).to be_a(Magic::Effects::ChooseACard)
      game.resolve_pending_effect(Magic::Cards::WoodElves)

      expect(p1.protected_from?(wood_elves)).to eq(true)

      subject.destroy!

      expect(p1.protected_from?(wood_elves)).to eq(false)
    end
  end
end
