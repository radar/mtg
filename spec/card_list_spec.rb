require 'spec_helper'

RSpec.describe Magic::CardList do
  let(:p1) { double(Magic::Player) }
  let(:p2) { double(Magic::Player) }

  let(:card_1) { double(Magic::Card, controller: p1) }
  let(:card_2) { double(Magic::Card, controller: p2) }

  subject { Magic::CardList.new([card_1, card_2]) }

  context "untapped" do
    it "returns only untapped cards" do
      tapped = double(Magic::Card, untapped?: false)
      untapped = double(Magic::Card, untapped?: true)

      expect(Magic::CardList.new([tapped, untapped]).untapped).to eq([untapped])
    end
  end

  context "controlled_by" do
    it "returns cards controlled by p1" do
      p1_cards = subject.controlled_by(p1)
      expect(p1_cards).to include(card_1)
      expect(p1_cards).not_to include(card_2)
    end
  end
end
