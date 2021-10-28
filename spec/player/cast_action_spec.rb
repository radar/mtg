require 'spec_helper'

RSpec.describe Magic::Player::CastAction do
  include_context "two player game"

  context "casting foundry inspector" do
    let(:foundry_inspector) { Card("Foundry Inspector") }
    before do
      p1.hand.add(foundry_inspector)
    end

    subject { described_class.new(game: game, player: p1, card: foundry_inspector) }

    context "when the player has 3 red mana" do
      before do
        p1.add_mana(red: 3)
      end

      it "is castable" do
        expect(subject.can_cast?).to eq(true)
      end
    end
  end

  context "casting path of peace" do
    let(:path_of_peace) { Card("Path Of Peace") }
    before do
      p1.hand.add(path_of_peace)
    end

    subject { described_class.new(game: game, player: p1, card: path_of_peace) }

    context "when the player has 3 red, 1 white mana" do
      before do
        p1.add_mana(red: 3, white: 1)
      end

      it "is castable" do
        expect(subject.can_cast?).to eq(true)
      end
    end
  end

  context "with an essence warden card" do
    let(:essence_warden) { Card("Essence Warden") }

    context "cannot cast a card that is not in the hand" do
      subject { described_class.new(game: game, player: p1, card: essence_warden) }

      it "cannot cast essence warden" do
        expect(subject.can_cast?).to eq(false)
      end
    end

    context "when essence warden is in the hand" do
      before do
        p1.hand.add(essence_warden)
      end

      context "when there is not enough mana in the player's mana pool" do
        subject { described_class.new(game: game, player: p1, card: essence_warden) }

        it "cannot cast essence warden" do
          expect(subject.can_cast?).to eq(false)
        end
      end

      context "when there is enough mana to pay the card's cost" do
        subject { described_class.new(game: game, player: p1, card: essence_warden) }

        before do
          p1.add_mana(green: 1)
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
      subject { described_class.new(game: game, player: p1, card: sol_ring) }

      before do
        p1.hand.add(sol_ring)
      end

      it "can cast the sol ring" do
        expect(subject.can_cast?).to eq(true)
      end
    end
  end
end
