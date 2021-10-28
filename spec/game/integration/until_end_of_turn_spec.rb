require 'spec_helper'

RSpec.describe Magic::Game, "until end of turn effect" do
  include_context "two player game"

  let(:dranas_emissary) { Card("Drana's Emissary", controller: p1) }

  before do
    game.battlefield.add(dranas_emissary)
  end

  def go_to_cleanup
    current_turn.upkeep!
    current_turn.draw!
    current_turn.first_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.finish_combat!
    current_turn.second_main!
    current_turn.end!
    current_turn.cleanup!
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

      go_to_cleanup

      expect(dranas_emissary.power).to eq(2)
    end
  end
end
