require 'spec_helper'

RSpec.describe Magic::Costs::Mana do

  context "can_pay?" do
    let(:player) { Magic::Player.new }

    context "when cost is 1 generic, 1 red" do
      subject { described_class.new({ generic: 1, red: 1 }) }

      context "when player has two red mana" do
        before do
          player.add_mana(red: 2)
        end

        it "can pay" do
          expect(subject.can_pay?(player)).to eq(true)
        end
      end

      context "when the player has two green mana" do
        before do
          player.add_mana(green: 2)
        end

        it "cannot pay" do
          expect(subject.can_pay?(player)).to eq(false)
        end
      end
    end
  end

  context "pay" do
    let(:player) { Magic::Player.new }

    context "when cost is 1 generic, 1 red" do
      subject { described_class.new({ generic: 1, red: 1 }) }

      context "when player has two red mana" do
        before do
          player.add_mana(red: 2)
        end

        it "can pay and finalize" do
          subject.pay({ generic: { red: 1 }, red: 1 })
          subject.finalize!(player)
        end
      end

      context "when the player has two green mana" do
        before do
          player.add_mana(green: 2)
        end

        it "cannot pay" do
          subject.pay({ generic: { red: 1 }, red: 1 })
          subject.finalize!(player)
        end
      end
    end
  end
end
