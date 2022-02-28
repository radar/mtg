require 'spec_helper'

RSpec.describe Magic::Cards::BasriKet do
  include_context "two player game"

  context "+1 triggered ability" do
    subject { Card("Basri Ket", controller: p1) }
    let(:ability) { subject.loyalty_abilities.first }
    let(:wood_elves) { Card("Wood Elves", controller: p2) }

    before do
      game.battlefield.add(wood_elves)
    end

    it "targets the wood elves" do
      subject.activate_loyalty_ability!(ability)
      expect(subject.loyalty).to eq(4)
      expect(wood_elves.power).to eq(2)
      expect(wood_elves.toughness).to eq(2)
      expect(wood_elves.indestructible?).to eq(true)
    end
  end

  context "-2 triggered ability" do
    subject { Card("Basri Ket", controller: p1) }
    let(:ability) { subject.loyalty_abilities[1] }

    let(:turn) { double(Magic::Game::Turn, number: 1) }
    before do
      allow(game).to receive(:current_turn) { turn }
    end

    it "adds an after attackers declared step trigger" do
      subject.activate_loyalty_ability!(ability)
      expect(subject.loyalty).to eq(1)
      expect(subject.delayed_responses.count).to eq(1)
      expect(subject.delayed_responses.first[:event_type]).to eq(Magic::Events::AttackersDeclared)
    end
  end

  context "-6 triggered ability" do
    subject { Card("Basri Ket", controller: p1, loyalty: 6) }
    let(:ability) { subject.loyalty_abilities.last }

    it "emblem for creating white soldier creature tokens and putting counters on all creatures" do
      subject.activate_loyalty_ability!(ability)
      expect(game.emblems.count).to eq(1)
    end
  end
end
