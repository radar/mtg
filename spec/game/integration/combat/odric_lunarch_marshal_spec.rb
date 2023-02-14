require 'spec_helper'

RSpec.describe Magic::Game, "combat -- first striker and Odric" do
  include_context "two player game"

  let!(:battlefield_raptor) { ResolvePermanent("Battlefield Raptor", owner: p1) }
  let!(:odric) { ResolvePermanent("Odric, Lunarch Marshal", owner: p1) }


  context "when in combat" do
    before do
      skip_to_combat!
    end

    it "odric gains flying and first strike from battlefield raptor" do
      expect(odric.flying?).to eq(true)
      expect(odric.first_strike?).to eq(true)
    end
  end
end
