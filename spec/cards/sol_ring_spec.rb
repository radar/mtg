require 'spec_helper'

RSpec.describe Magic::Cards::SolRing do
  let(:p1) { Magic::Player.new }
  subject { described_class.new(controller: p1) }

  context "tap" do
    it "taps for two colorless mana" do
      subject.tap!
      expect(subject).to be_tapped
      expect(p1.mana_pool[:colorless]).to eq(2)
    end
  end
end
