require 'spec_helper'

RSpec.describe Magic::Permanent do
  include_context "two player game"

  context "moving to graveyard" do
    context "when permanent is not a token" do
      let!(:permanent) { ResolvePermanent("Scute Swarm", owner: p1) }

      it "moves the related card to the graveyard" do
        permanent.destroy!
        expect(p1.graveyard.by_name("Scute Swarm").count).to eq(1)
      end
    end

    context "when permanent is a token" do
      let!(:permanent) { ResolvePermanent("Scute Swarm", owner: p1, token: true, copy: true) }

      it "does not move the card to the graveyard" do
        permanent.destroy!
        expect(p1.graveyard.by_name("Scute Swarm").count).to eq(0)
      end
    end
  end

  context "becomes" do
    let(:permanent) { ResolvePermanent("Riddleform", owner: p1) }

    it "becomes a 3/3 Sphinx creature with flying", aggregate_failures: true do
      permanent.add_types(Magic::Types::Creature, Magic::Types::Creatures["Sphinx"])
      permanent.modify_base_power(3)
      permanent.modify_base_toughness(3)
      permanent.grant_keyword(Magic::Keywords::FLYING)

      game.tick!

      expect(permanent).to be_a_creature
      expect(permanent.type?("Sphinx")).to eq(true)
      expect(permanent.power).to eq(3)
      expect(permanent.toughness).to eq(3)
      expect(permanent.flying?).to eq(true)
    end
  end
end
