# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GibberingFiend do
  include_context "two player game"

  subject(:gibbering_fiend) { ResolvePermanent("Gibbering Fiend", owner: p1) }

  it "is a 2/1 Devil" do
    expect(gibbering_fiend.power).to eq(2)
    expect(gibbering_fiend.toughness).to eq(1)
    expect(gibbering_fiend.type?("Devil")).to be true
  end

  it "deals 1 damage to each opponent when it enters" do
    expect { gibbering_fiend }.to change { p2.life }.by(-1)
  end

  context "delirium" do
    def fill_graveyard_with_types(*names)
      names.each { |name| p1.graveyard.add(Card(name, owner: p1)) }
    end

    it "does not deal damage on an opponent's upkeep without four card types in the graveyard" do
      gibbering_fiend
      fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt")

      expect {
        game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
      }.not_to change { p2.life }
    end

    it "deals 1 damage to that player on an opponent's upkeep with four or more card types in the graveyard" do
      gibbering_fiend
      fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt", "Rampant Growth")

      expect {
        game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
        game.settle!
      }.to change { p2.life }.by(-1)
    end

    it "does not trigger on its controller's own upkeep" do
      gibbering_fiend
      fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt", "Rampant Growth")

      expect {
        game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
      }.not_to change { p1.life }
    end
  end
end
