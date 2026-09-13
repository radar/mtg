# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Panharmonicon do
  include_context "two player game"

  subject!(:panharmonicon) { ResolvePermanent("Panharmonicon", owner: p1) }

  context "when an artifact or creature you control enters and triggers an ability of a permanent you control" do
    let!(:elderfang_ritualist) { ResolvePermanent("Elderfang Ritualist", owner: p1) }

    it "triggers that ability an additional time" do
      ResolvePermanent("Dwynen's Elite", owner: p1)

      expect(p1.creatures.by_name("Elf Warrior").count).to eq(2)
    end
  end

  context "when a land (neither artifact nor creature) enters and triggers landfall" do
    let!(:tireless_tracker) { ResolvePermanent("Tireless Tracker", owner: p1) }

    it "does not double the triggered ability" do
      land = Card("Forest", owner: p1)
      p1.hand.add(land)
      p1.play_land(land: land)

      expect(p1.permanents.select { |permanent| permanent.name == "Clue" }.count).to eq(1)
    end
  end

  context "when the permanent whose ability triggers is controlled by an opponent" do
    let!(:elderfang_ritualist) { ResolvePermanent("Elderfang Ritualist", owner: p2) }

    it "does not double that ability" do
      ResolvePermanent("Dwynen's Elite", owner: p2)

      expect(p2.creatures.by_name("Elf Warrior").count).to eq(1)
    end
  end
end
