# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheSwarmweaver do
  include_context "two player game"

  subject(:swarmweaver) { ResolvePermanent("The Swarmweaver", owner: p1) }

  def insects = p1.creatures.select { _1.type?("Insect") }

  def fill_graveyard_with_types(*names)
    names.each { |name| p1.graveyard.add(Card(name, owner: p1)) }
  end

  it "is a legendary 2/3 artifact Scarecrow" do
    expect(swarmweaver.power).to eq(2)
    expect(swarmweaver.toughness).to eq(3)
    expect(swarmweaver.legendary?).to be true
    expect(swarmweaver.artifact?).to be true
  end

  it "creates two 1/1 flying Insect tokens when it enters" do
    swarmweaver
    game.settle!
    expect(insects.count).to eq(2)
    expect(insects).to all(have_attributes(power: 1, toughness: 1))
    expect(insects).to all(satisfy { _1.has_keyword?(Magic::Cards::Keywords::FLYING) })
  end

  context "delirium" do
    before do
      swarmweaver
      game.settle!
    end

    it "does not boost Insects without four card types in the graveyard" do
      fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt")
      game.tick!
      expect(insects.map(&:power)).to eq([1, 1])
      expect(insects.first.has_keyword?(Magic::Cards::Keywords::DEATHTOUCH)).to be false
    end

    it "gives Insects +1/+1 and deathtouch with four card types, but not other creatures" do
      fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt", "Rampant Growth")
      game.tick!
      expect(insects.map(&:power)).to eq([2, 2])
      expect(insects.map(&:toughness)).to eq([2, 2])
      expect(insects).to all(satisfy { _1.has_keyword?(Magic::Cards::Keywords::DEATHTOUCH) })
      expect(swarmweaver.power).to eq(2)
    end

    it "does not boost the opponent's Insects" do
      fill_graveyard_with_types("Grizzly Bears", "Island", "Lightning Bolt", "Rampant Growth")
      theirs = ResolvePermanent("Scute Swarm", owner: p2)
      game.tick!
      expect(theirs.power).to eq(1)
    end
  end
end
