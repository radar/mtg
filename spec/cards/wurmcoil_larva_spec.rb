# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WurmcoilLarva do
  include_context "two player game"

  let!(:larva) { ResolvePermanent("Wurmcoil Larva", owner: p1) }

  def wurms = p1.creatures.select { |creature| creature.name == "Phyrexian Wurm" }

  it "is a 3/3 artifact Phyrexian Wurm with deathtouch and lifelink" do
    expect([larva.power, larva.toughness]).to eq([3, 3])
    expect(larva.card).to be_artifact
    expect(larva.type?("Wurm")).to be(true)
    expect(larva.keywords).to include(Magic::Cards::Keywords::DEATHTOUCH, Magic::Cards::Keywords::LIFELINK)
  end

  context "when it dies" do
    before do
      larva.destroy!
      game.settle!
    end

    it "creates two Wurm tokens" do
      expect(wurms.size).to eq(2)
    end

    it "creates a 1/2 black artifact Phyrexian Wurm with deathtouch" do
      token = wurms.detect { |wurm| wurm.power == 1 }

      expect([token.power, token.toughness]).to eq([1, 2])
      expect(token.keywords).to include(Magic::Cards::Keywords::DEATHTOUCH)
      expect(token.keywords).not_to include(Magic::Cards::Keywords::LIFELINK)
      expect(token.card).to be_artifact
      expect(token.type?("Phyrexian")).to be(true)
      expect(token.card.colors).to eq([:black])
    end

    it "creates a 2/1 black artifact Phyrexian Wurm with lifelink" do
      token = wurms.detect { |wurm| wurm.power == 2 }

      expect([token.power, token.toughness]).to eq([2, 1])
      expect(token.keywords).to include(Magic::Cards::Keywords::LIFELINK)
      expect(token.keywords).not_to include(Magic::Cards::Keywords::DEATHTOUCH)
      expect(token.card).to be_artifact
      expect(token.card.colors).to eq([:black])
    end
  end
end
