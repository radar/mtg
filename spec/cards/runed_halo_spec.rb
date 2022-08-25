require 'spec_helper'

RSpec.describe Magic::Cards::RunedHalo do
  include_context "two player game"
  subject { Card("Runed Halo") }
  let(:wood_elves) { Card("Wood Elves") }

  context "when runed halo enters the battlefield" do

    it "triggers a 'choose a card' effect" do
      cast_and_resolve(card: subject, player: p1)
      effect = game.effects.first
      expect(effect).to be_a(Magic::Effects::ChooseACard)
      game.resolve_pending_effect(Magic::Cards::WoodElves)

      runed_halo = p1.permanents.by_name("Runed Halo").first
      expect(runed_halo.protections.count).to eq(1)
      expect(runed_halo.protections.first.protects_player?).to eq(true)
      expect(p1.protected_from?(wood_elves)).to eq(true)

      runed_halo.destroy!

      expect(p1.protected_from?(wood_elves)).to eq(false)
    end
  end
end
