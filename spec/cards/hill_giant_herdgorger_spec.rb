require 'spec_helper'

RSpec.describe Magic::Cards::HillGiantHerdgorger do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:card) { described_class.new(game: game, controller: p1) }

  context "ETB Event" do
    let(:event) do
      Magic::Events::EnteredTheBattlefield.new(
        card,
      )
    end

    it "adds a life to controller's life total" do
      expect { card.receive_notification(event) }.to change { p1.life }.by(3)
    end
  end
end
