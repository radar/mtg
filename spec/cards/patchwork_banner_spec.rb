# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PatchworkBanner do
  include_context "two player game"

  let!(:banner) { ResolvePermanent("Patchwork Banner", owner: p1) }

  context "when entering the battlefield" do
    it "presents a choice to choose a creature type" do
      expect(game.choices.last).to be_a(described_class::CreatureTypeChoice)
    end
  end

  context "after choosing a creature type" do
    let!(:elf) { ResolvePermanent("Elvish Mystic", owner: p1) }
    let!(:opponents_elf) { ResolvePermanent("Elvish Mystic", owner: p2) }
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      game.resolve_choice!(creature_type: "Elf")
      game.tick!
    end

    it "gives creatures you control of the chosen type +1/+1" do
      expect(elf.power).to eq(2)
      expect(elf.toughness).to eq(2)
    end

    it "does not affect creatures of a different type" do
      expect(bear.power).to eq(2)
      expect(bear.toughness).to eq(2)
    end

    it "does not affect an opponent's creatures of the chosen type" do
      expect(opponents_elf.power).to eq(1)
      expect(opponents_elf.toughness).to eq(1)
    end
  end

  context "activated ability" do
    it "adds one mana of any color" do
      p1.activate_ability(ability: banner.activated_abilities.first) { |a| a.choose(:blue) }
      expect(p1.mana_pool[:blue]).to eq(1)
    end
  end
end
