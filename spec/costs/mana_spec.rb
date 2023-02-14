require 'spec_helper'

RSpec.describe Magic::Costs::Mana do

  context "0 cost" do
    let(:player) { Magic::Player.new }
    subject { described_class.new(0) }

    it "accepts 0 as an argument" do
      expect(subject.can_pay?(player)).to eq(true)
    end
  end

  context "string argument" do
    context "1 generic" do
      subject { described_class.new("{1}") }
      it "costs one generic mana" do
        expect(subject.cost).to eq({ generic: 1 })
      end
    end

    context "4 generic, 2 white" do
      subject { described_class.new("{4}{W}{W}") }
      it "costs 4 generic, 2 white" do
        expect(subject.cost).to eq({ generic: 4, white: 2 })
      end
    end
  end

  context "cost reduction" do
    subject { described_class.new({ generic: 3, red: 1 }).reduced_by(generic: -> { 2 }) }

    it "reduces generic cost by 2" do
      expect(subject.cost).to eq({ generic: 1, red: 1 })
      expect(subject.balance).to eq({ generic: 1, red: 1 })
    end
  end

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
          subject.pay(player, { generic: { red: 1 }, red: 1 })
          subject.finalize!(player)
        end
      end

      context "when the player has two green mana" do
        before do
          player.add_mana(green: 2)
        end

        it "cannot pay" do
          expect { subject.pay(player, { generic: { red: 1 }, red: 1 }) }.to raise_error(Magic::Costs::Mana::CannotPay)
        end
      end
    end
  end
end
