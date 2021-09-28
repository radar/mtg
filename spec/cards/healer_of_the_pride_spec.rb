require 'spec_helper'

RSpec.describe Magic::Cards::HealerOfThePride do
  let(:game) { Magic::Game.new }
  let(:p1) { Magic::Player.new(game: game) }
  let(:loxodon_wayfarer) { Magic::Cards::LoxodonWayfarer.new(game: game, controller: p1) }
  let(:card) { described_class.new(game: game, controller: p1) }

  context "when another creature controlled by this player enters the battlefield" do
    let(:event) do
      Magic::Events::ZoneChange.new(
        loxodon_wayfarer,
        from: :hand,
        to: :battlefield
      )
    end

    it "adds a life to player's life total" do
      expect { card.receive_notification(event) }.to change { p1.life }.by(2)
    end
  end
end
