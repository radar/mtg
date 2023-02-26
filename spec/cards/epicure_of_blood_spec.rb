require 'spec_helper'

RSpec.describe Magic::Cards::EpicureOfBlood do
  include_context "two player game"

  subject! { ResolvePermanent("Epicure Of Blood", owner: p1) }

  context "triggered by another card" do
    let(:resolve_hill_giant_herdgorger) { ResolvePermanent("Hill Giant Herdgorger", owner: p1) }

    it "deals damage to other player" do
      expect do
        resolve_hill_giant_herdgorger
      end.to(change { p2.life }.by(-1))
    end

    it "does not deal damage to controller" do
      # Hill Giant Herdgorger ETBs and grants controller +3 life
      # If Epicure of Blood incorrectly targetted P1, this life gain would only be 2.
      expect { resolve_hill_giant_herdgorger }.to(change { p1.life }.by(3))
    end
  end
end
