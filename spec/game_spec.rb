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

    subject { Magic::Game.new(players: [p1, p2]) }

    before do
      subject.battlefield.add(p1_forest)
    end

    it "transitions between each stage" do
      expect(subject).to be_at_step(:untap)
      subject.next_step
      expect(subject).to be_at_step(:upkeep)

      expect(p1).to receive(:draw!)
      subject.next_step
      expect(subject).to be_at_step(:draw)

      subject.next_step
      expect(subject).to be_at_step(:first_main)

      subject.next_step
      expect(subject).to be_at_step(:beginning_of_combat)

      combat = Magic::Game::CombatPhase.new(game: subject)
      expect(combat).to be_at_step(:beginning_of_combat)

      combat.next_step
      expect(combat).to be_at_step(:declare_attackers)

      combat.next_step
      expect(combat).to be_at_step(:end_of_combat)

      expect(subject).to be_at_step(:end_of_combat)

      subject.next_step
      expect(subject).to be_at_step(:second_main)

      subject.next_step
      expect(subject).to be_at_step(:end_of_turn)

      subject.next_step
      expect(subject).to be_at_step(:cleanup)

      subject.next_step
      expect(subject).to be_at_step(:untap)

      expect(subject.active_player).to eq(p2)
      expect(p1_forest).to be_untapped

      subject.next_step
      expect(subject).to be_at_step(:upkeep)

      expect(p2).to receive(:draw!)
      subject.next_step
    end
  end
end
