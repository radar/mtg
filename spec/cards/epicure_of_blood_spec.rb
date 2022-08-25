require 'spec_helper'

RSpec.describe Magic::Cards::EpicureOfBlood do
  include_context "two player game"

  subject { Permanent("Epicure Of Blood", controller: p1, game: game) }

  context "receive notification" do
    let(:event) do
      Magic::Events::LifeGain.new(
        player: p1,
        life: 1
      )
    end

    it "deals damage to other player" do
      expect { subject.receive_notification(event) }.to(change { p2.life }.by(-1))
    end

    it "does not deal damage to controller" do
      expect { subject.receive_notification(event) }.not_to(change { p1.life })
    end
  end

  context "triggered by another card" do
    let(:hill_giant_herdgorger) { Card("Hill Giant Herdgorger") }

    before do
      game.battlefield.add(subject)
    end

    def hill_giant_etb
      cast_and_resolve(card: hill_giant_herdgorger, player: p1)
    end

    it "deals damage to other player" do
      expect do
        hill_giant_etb
      end.to(change { p2.life }.by(-1))
    end

    it "does not deal damage to controller" do
      # Hill Giant Herdgorger ETBs and grants controller +3 life
      # If Epicure of Blood incorrectly targetted P1, this life gain would only be 2.
      expect { hill_giant_etb }.to(change { p1.life }.by(3))
    end
  end
end
