require 'spec_helper'

RSpec.describe Magic::Game do
  let(:p1) { Magic::Player.new }
  let(:p2) { Magic::Player.new }


  context "active player" do
    subject { Magic::Game.new(players: [p1, p2] )}
    it "first player in list is active player" do
      expect(subject.active_player).to eq(p1)
    end
  end

  context "state machine" do
    let(:p1_forest) { Magic::Cards::Forest.new(controller: p1, tapped: true) }
    let(:battlefield) { Magic::Battlefield.new(cards: [p1_forest]) }

    subject { Magic::Game.new(players: [p1, p2], battlefield: battlefield ) }

    it "transitions between each stage" do
      expect(subject).to be_untap
      subject.upkeep
      expect(subject).to be_upkeep

      expect(p1).to receive(:draw!)
      subject.draw
      expect(subject).to be_draw

      subject.cleanup
      expect(subject.active_player).to eq(p2)
      expect(p1_forest).to be_untapped

      expect(subject).to be_untap
      subject.upkeep
      expect(subject).to be_upkeep

      expect(p2).to receive(:draw!)
      subject.draw
    end
  end
end
