require 'spec_helper'

RSpec.describe Magic::Zones::Library do
  let(:island) { Magic::Cards::Island.new }
  subject { described_class.new(cards: [island]) }

  context "#draw" do
    it "draws a card from the library" do
      card = subject.draw
      expect(subject.cards.count).to eq(0)
    end
  end
end
