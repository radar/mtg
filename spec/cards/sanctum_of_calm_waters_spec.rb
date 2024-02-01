require 'spec_helper'

RSpec.describe Magic::Cards::SanctumOfCalmWaters do
  include_context "two player game"


  let!(:sanctum_of_tranquil_light) { ResolvePermanent("Sanctum Of Tranquil Light") }
  let!(:sanctum_of_calm_waters) { ResolvePermanent("Sanctum Of Calm Waters") }

  context "at beginning of precombat main phase" do
    it "chooses to draw & discard" do
      go_to_main_phase!
      expect(p1).to receive(:draw!).twice

      choice = game.choices.first
      expect(choice).to be_a(described_class::Choice)
      game.resolve_choice!

      choice = game.choices.first
      expect(choice).to be_a(Magic::Choice::Discard)
      game.resolve_choice!(card: p1.hand.cards.first)
    end
  end
end
