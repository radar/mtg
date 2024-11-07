require 'spec_helper'

RSpec.describe Magic::Cards::AvenGagglemaster do
  include_context "two player game"

  subject { ResolvePermanent("Aven Gagglemaster", owner: p1) }

  context "when it enters the battlefield" do
    it "gains life for itself" do
      expect { subject }.to change { p1.life }.by(2)
    end

    context "when another aven gagglemaster is on the field" do
      before do
        ResolvePermanent("Aven Gagglemaster", owner: p1)
      end

      it "gains life for itself and the other flying creature" do
        expect { subject }.to change { p1.life }.by(4)
      end
    end
  end
end
