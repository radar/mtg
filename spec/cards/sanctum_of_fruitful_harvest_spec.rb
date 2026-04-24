# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::SanctumOfFruitfulHarvest do
  include_context "two player game"

  let!(:sanctum_of_tranquil_light) { ResolvePermanent("Sanctum Of Tranquil Light") }
  let!(:sanctum_of_fruitful_harvest) { ResolvePermanent("Sanctum Of Fruitful Harvest") }

  context "at beginning of precombat main phase" do
    it "adds mana equal to the number of shrines in the chosen color" do
      go_to_main_phase!

      choice = game.choices.first
      expect(choice).to be_a(described_class::ColorChoice)
      game.resolve_choice!(color: :green)

      expect(p1.mana_pool[:green]).to eq(2)
    end
  end
end
