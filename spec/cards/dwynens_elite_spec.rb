# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DwynensElite do
  include_context "two player game"

  context "when you control another Elf" do
    let!(:other_elf) { ResolvePermanent("Elderfang Ritualist", owner: p1) }
    subject!(:dwynens_elite) { ResolvePermanent("Dwynen's Elite", owner: p1) }

    it "creates a 1/1 green Elf Warrior token" do
      tokens = p1.creatures.by_name("Elf Warrior")
      expect(tokens.count).to eq(1)
      expect(tokens.first.power).to eq(1)
      expect(tokens.first.toughness).to eq(1)
    end
  end

  context "when you don't control another Elf" do
    subject!(:dwynens_elite) { ResolvePermanent("Dwynen's Elite", owner: p1) }

    it "does not create a token" do
      expect(p1.creatures.by_name("Elf Warrior").count).to eq(0)
    end
  end

  context "when an opponent controls another Elf" do
    subject!(:dwynens_elite) { ResolvePermanent("Dwynen's Elite", owner: p1) }
    let!(:opponents_elf) { ResolvePermanent("Elvish Warmaster", owner: p2) }

    it "does not create a token" do
      expect(p1.creatures.by_name("Elf Warrior").count).to eq(0)
    end
  end
end
