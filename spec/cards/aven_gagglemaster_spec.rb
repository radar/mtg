require 'spec_helper'

RSpec.describe Magic::Cards::AvenGagglemaster do
  include_context "two player game"

  subject { Permanent("Aven Gagglemaster", owner: p1) }
  let(:etb_event) { instance_double(Magic::Events::EnteredTheBattlefield, permanent: subject) }

  before do
    game.battlefield.add(subject)
  end

  context "when it enters the battlefield" do

    it "gains life for itself" do
      expect { subject.entered_the_battlefield!(etb_event) }.to change { p1.life }.by(2)
    end

    context "when another aven gagglemaster is on the field" do
      before do
        game.battlefield.add(Permanent("Aven Gagglemaster", owner: p1))
      end

      it "gains life for itself and the other flying creature" do
        expect { subject.entered_the_battlefield!(etb_event) }.to change { p1.life }.by(4)
      end
    end
  end
end
