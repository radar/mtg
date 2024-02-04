require "spec_helper"

RSpec.describe Magic::Cards::ChromeReplicator do
  include_context "two player game"

  context "etb" do
    it "does nothing if conditions aren't met" do
      ResolvePermanent("Chrome Replicator")
      expect(game.battlefield.creatures.count).to eq(1)
    end

    it "create a 4/4 colorless Construct artifact creature token." do
      2.times { ResolvePermanent("Wood Elves") }

      ResolvePermanent("Chrome Replicator")
      expect(game.battlefield.creatures.count).to eq(4)
      construct = game.battlefield.creatures.by_name("Construct").first
      expect(construct).to be_a_token
      expect(construct).to be_colorless
      expect(construct).to be_an_artifact
      expect(construct.power).to eq(4)
      expect(construct.toughness).to eq(4)
    end
  end
end
