require 'spec_helper'

RSpec.describe Magic::Cards::CloudkinSeer do
  include_context "two player game"

  let(:forest) { Card("Forest") }

  before do
    p1.library.add(forest)
  end

  subject { ResolvePermanent("Cloudkin Seer", owner: p1) }

  context "ETB effect" do
    it "controller draws a card" do
      expect(p1).to receive(:draw!)
      subject
    end
  end

  context "flying?" do
    it "is flying" do
      expect(subject).to be_flying
    end
  end
end
