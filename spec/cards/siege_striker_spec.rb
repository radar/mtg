require 'spec_helper'

RSpec.describe Magic::Cards::SiegeStriker do
  include_context "two player game"

  subject(:siege_striker) { ResolvePermanent("Siege Striker", controller: p1) }
  let(:wood_elves) { ResolvePermanent("Wood Elves", controller: p1) }

  before do
    skip_to_combat!
  end

  context "power buff" do
    it "increases in power when other creature tapped during combat" do
      current_turn.declare_attackers!

      current_turn.declare_attacker(
        siege_striker,
        target: p2,
      )

      expect(siege_striker.power).to eq(1)
      expect(siege_striker.toughness).to eq(1)

      action = Magic::Actions::TapPermanent.new(player: p1, permanent: wood_elves)
      game.take_action(action)

      expect(siege_striker.power).to eq(2)
      expect(siege_striker.toughness).to eq(2)
    end

    it "does not increase in power outside of combat" do
      expect(siege_striker.power).to eq(1)
      expect(siege_striker.toughness).to eq(1)

      action = Magic::Actions::TapPermanent.new(player: p1, permanent: wood_elves)
      game.take_action(action)

      expect(siege_striker.power).to eq(1)
      expect(siege_striker.toughness).to eq(1)
    end
  end
end
