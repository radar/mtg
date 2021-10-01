require 'spec_helper'

RSpec.describe Magic::Cards::ExquisiteBlood do
  let(:game) { Magic::Game.new }
  let(:p1) { game.add_player }
  let(:p2) { game.add_player }

  subject { Card("Exquisite Blood", controller: p1) }

  context "receive notification" do
    it "controller gains life equal to life lost" do
      subject.receive_notification(
        Magic::Events::LifeLoss.new(
          player: p2,
          life: 6
        )
      )

      expect(p1.life).to eq(26)
    end
  end
end
