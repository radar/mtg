require 'spec_helper'

RSpec.describe Magic::Cards::HealerOfThePride do
  include_context "two player game"

  let(:loxodon_wayfarer) { Card("Loxodon Wayfarer", game: game, controller: p1) }
  let(:card) { described_class.new(game: game, controller: p1) }

  context "when another creature controlled by this player enters the battlefield" do
    let(:event) do
      Magic::Events::EnteredTheBattlefield.new(
        loxodon_wayfarer,
      )
    end

    it "adds a life to player's life total" do
      expect { card.receive_notification(event) }.to change { p1.life }.by(2)
    end
  end
end
