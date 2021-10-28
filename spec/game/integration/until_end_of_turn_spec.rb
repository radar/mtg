require 'spec_helper'

RSpec.describe Magic::Game, "until end of turn effect" do
  include_context "two player game"

  before do
    p1.library.add(Card("Forest"))
  end
  let(:dranas_emissary) { Card("Drana's Emissary", controller: p1) }

  before do
    game.battlefield.add(dranas_emissary)
  end

  def go_to_cleanup
    until current_turn.at_step?(:cleanup)
      current_turn.next_step
    end
  end

  context "granted keywords" do
    before do
      dranas_emissary.grant_keyword(Magic::Card::Keywords::DEATHTOUCH, until_eot: true)
    end

    it "granted keywords are cleared at end of turn" do
      go_to_cleanup

      expect(dranas_emissary.deathtouch?).to eq(false)
      expect(dranas_emissary.power).to eq(2)
    end
  end

  context "eot modifiers" do
    before do
      dranas_emissary.modifiers << double(power: 3, until_eot?: true)
    end

    it "eot modifiers are cleared at end of turn" do
      expect(dranas_emissary.power).to eq(5)

      until current_turn.at_step?(:cleanup)
        current_turn.next_step
      end

      expect(dranas_emissary.power).to eq(2)
    end
  end
end
