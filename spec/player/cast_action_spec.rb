require 'spec_helper'

RSpec.describe Magic::Player::CastAction do
  let(:game) { Magic::Game.new }
  let(:player) { game.add_player }

  context "with an essence warden card" do
    let(:essence_warden) { Card("Essence Warden") }

    context "cannot cast a card that is not in the hand" do
      subject { described_class.new(game: game, player: player, card: essence_warden) }

      it "cannot cast essence warden" do
        expect(subject.can_cast?).to eq(false)
      end
    end

    context "when essence warden is in the hand" do
      before do
        player.hand.add(essence_warden)
      end

      context "when there is not enough mana in the player's mana pool" do
        subject { described_class.new(game: game, player: player, card: essence_warden) }

        it "cannot cast essence warden" do
          expect(subject.can_cast?).to eq(false)
        end
      end

      context "when there is enough mana to pay the card's cost" do
        subject { described_class.new(game: game, player: player, card: essence_warden) }

        before do
          player.add_mana(green: 1)
        end

        it "can cast the essence warden" do
          expect(subject.can_cast?).to eq(true)
        end
      end
    end
  end

  context "with a foundry inspector on the battlefield" do
    let(:foundry_inspector) { Card("Foundry Inspector") }

    before do
      game.battlefield.add(foundry_inspector)
      foundry_inspector.entered_the_battlefield!
    end

    context "with a sol ring in hand" do
      let(:sol_ring) { Card("Sol Ring") }
      subject { described_class.new(game: game, player: player, card: sol_ring) }

      before do
        player.hand.add(sol_ring)
      end

      it "can cast the sol ring" do
        expect(subject.can_cast?).to eq(true)
      end
    end
  end
end
