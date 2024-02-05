require 'spec_helper'

RSpec.describe Magic::Cards::ScuteSwarm do
  include_context "two player game"

  subject { ResolvePermanent("Scute Swarm", owner: p1) }
  let(:forest) { Card("Forest") }
  before do
    p1.hand.add(forest)
  end

  context "landfall" do
    context "when controller controls less than 6 lands" do
      it "creates an insect" do
        subject
        p1.play_land(land: forest)
        game.tick!

        expect(creatures.controlled_by(p1).by_name("Insect").count).to eq(1)
      end
    end

    context "when controller controls more than 6 lands" do
      before do
        6.times { ResolvePermanent("Forest", owner: p1) }
      end

      it "creates a token copy of Scute Swarm" do
        subject
        p1.play_land(land: forest)
        game.tick!

        scutes = creatures.controlled_by(p1).by_name("Scute Swarm")

        expect(scutes.count).to eq(2)
        expect(scutes.count(&:token?)).to eq(1)
      end
    end

    context "when controller owns two scutes" do
      before do
        6.times { ResolvePermanent("Forest", owner: p1) }
      end

      it "creates a token copy of Scute Swarm" do
        subject
        ResolvePermanent("Scute Swarm", owner: p1)
        p1.play_land(land: forest)
        game.tick!

        scutes = creatures.controlled_by(p1).by_name("Scute Swarm")

        expect(scutes.count).to eq(4)
        expect(scutes.count(&:token?)).to eq(2)
      end
    end
  end
end
