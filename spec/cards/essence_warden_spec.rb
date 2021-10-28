require 'spec_helper'

RSpec.describe Magic::Cards::EssenceWarden do
  include_context "two player game"

  let(:card) { described_class.new(game: game, controller: p1) }

  context "when another creature controlled by the same controller enters the battlefield" do
    let(:loxodon_wayfarer) { Card("Loxodon Wayfarer", game: game, controller: p1) }
    let(:event) do
      Magic::Events::EnteredTheBattlefield.new(
        loxodon_wayfarer,
      )
    end

    it "adds a life to controller's life total" do
      expect { card.receive_notification(event) }.to change { p1.life }.by(1)
    end
  end

  context "when another creature controlled by a different controller enters the battlefield" do
    let(:loxodon_wayfarer) { Card("Loxodon Wayfarer", game: game, controller: p2) }
    let(:event) do
      Magic::Events::EnteredTheBattlefield.new(
        loxodon_wayfarer,
      )
    end

    it "adds a life to controller's life total" do
      expect { card.receive_notification(event) }.to change { p1.life }.by(1)
    end
  end

  context "when a creature controlled by this controller moves to the graveyard" do
    let(:loxodon_wayfarer) { Card("Loxodon Wayfarer", game: game, controller: p2) }
    let(:event) do
      Magic::Events::LeavingZone.new(
        loxodon_wayfarer,
        from: :battlefield,
        to: :graveyard
      )
    end

    it "adds no life" do
      expect { card.receive_notification(event) }.not_to change { p1.life }
    end
  end
end
