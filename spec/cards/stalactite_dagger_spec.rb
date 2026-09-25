# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StalactiteDagger do
  include_context "two player game"

  let!(:dagger) { ResolvePermanent("Stalactite Dagger", owner: p1) }

  it "creates a 1/1 colorless Shapeshifter token with changeling when it enters" do
    token = p1.creatures.find(&:token?)
    expect(token.name).to eq("Shapeshifter")
    expect([token.power, token.toughness]).to eq([1, 1])
    expect(token).to be_colorless
    expect(token).to be_changeling
  end

  it "makes the changeling token every creature type" do
    token = p1.creatures.find(&:token?)
    expect(token).to be_type("Goblin")
    expect(token).to be_type("Elf")
    expect(p1.creatures.by_type("Faerie")).to include(token)
  end

  context "when equipped" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      p1.add_mana(red: 2)
      p1.activate_ability(ability: dagger.activated_abilities.first) do
        _1.targeting(bears)
        _1.pay_mana(generic: { red: 2 })
      end
      game.stack.resolve!
      game.tick!
    end

    it "gives the equipped creature +1/+1" do
      expect([bears.power, bears.toughness]).to eq([3, 3])
    end

    it "makes the equipped creature all creature types" do
      expect(bears).to be_type("Bear")
      expect(bears).to be_type("Goat")
      expect(bears).to be_type("Merfolk")
    end

    it "stops once the Equipment is unattached" do
      dagger.detach!
      game.tick!
      expect(bears).not_to be_type("Goat")
      expect(bears.power).to eq(2)
    end
  end

  it "doesn't make an unequipped creature all creature types" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    expect(bears).not_to be_type("Goat")
  end
end
