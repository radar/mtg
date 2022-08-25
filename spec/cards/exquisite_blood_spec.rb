require 'spec_helper'

RSpec.describe Magic::Cards::ExquisiteBlood do
  include_context "two player game"

  subject { ResolvePermanent("Exquisite Blood", controller: p1) }

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
