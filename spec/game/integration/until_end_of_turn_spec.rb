require 'spec_helper'

RSpec.describe Magic::Game, "until end of turn effect" do
  include_context "two player game"

  let!(:dranas_emissary) { ResolvePermanent("Drana's Emissary", owner: p1) }

  def go_to_cleanup
    current_turn.untap!
    current_turn.upkeep!
    current_turn.draw!
    current_turn.first_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    current_turn.end!
    current_turn.cleanup!
  end

  context "granted keywords" do
    before do
      dranas_emissary.grant_keyword(Magic::Keywords::DEATHTOUCH, until_eot: true)
    end

    it "granted keywords are cleared at end of turn" do
      go_to_cleanup
      expect(dranas_emissary.deathtouch?).to eq(false)
      expect(dranas_emissary.power).to eq(2)
    end
  end

  context "eot modifiers" do
    before do
      dranas_emissary.modifiers << Magic::Permanents::Modifications::Power.new(power_modification: 3, until_eot: true)
    end

    it "eot modifiers are cleared at end of turn" do
      game.tick!
      expect(dranas_emissary.power).to eq(5)

      go_to_cleanup

      expect(dranas_emissary.power).to eq(2)
    end
  end

  context "protections" do
    before do
      dranas_emissary.gains_protection_from_color(:green, until_eot: true)
    end

    it "granted protections are cleaned up at end of turn" do
      go_to_cleanup
      expect(dranas_emissary).not_to be_protected_from(Card("Wood Elves"))
    end
  end
end
