# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Card do
  include_context "two player game"
  subject { Card("Forest") }

  before do
    p1.library.add(subject)
  end

  context "destroy!" do
    it "moves the card to the graveyard" do
      subject.discard!
      expect(subject.zone).to be_graveyard
    end
  end

  context "revealing" do
    it "is not revealed by default" do
      expect(subject).not_to be_revealed
    end

    it "can be revealed and concealed" do
      subject.reveal!
      expect(subject).to be_revealed

      subject.conceal!
      expect(subject).not_to be_revealed
    end

    it "notifies the game when revealed" do
      subject.reveal!
      revealed_event = game.current_turn.events.find { |e| e.is_a?(Magic::Events::CardsRevealed) }
      expect(revealed_event).not_to be_nil
      expect(revealed_event.cards).to eq([subject])
    end

    it "resets revealed status when moving zones" do
      subject.reveal!
      expect(subject).to be_revealed

      subject.move_to_hand!
      expect(subject).not_to be_revealed
    end
  end
end
