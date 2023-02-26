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
      let!(:permanent) { ResolvePermanent("Scute Swarm", owner: p1, token: true) }

      it "does not move the card to the graveyard" do
        permanent.destroy!
        expect(p1.graveyard.by_name("Scute Swarm").count).to eq(0)
      end
    end
  end
end
