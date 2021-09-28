require 'spec_helper'

RSpec.describe Magic::Cards::EpicureOfBlood do
  let(:p1) { Magic::Player.new }
  let(:p2) { Magic::Player.new }
  let(:game) { Magic::Game.new }
  subject { Card("Epicure Of Blood", controller: p1, game: game) }

  before do
    game.add_player(p1)
    game.add_player(p2)
  end

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
    let(:hill_giant_herdgorger) { Card("Hill Giant Herdgorger", controller: p1, game: game) }

    before do
      game.battlefield.add(subject)
    end

    it "deals damage to other player" do
      expect do
        hill_giant_herdgorger.cast!
        game.stack.resolve!
      end.to(change { p2.life }.by(-1))
    end

    it "does not deal damage to controller" do
      expect { subject.receive_notification(event) }.not_to(change { p1.life })
    end
  end
end
