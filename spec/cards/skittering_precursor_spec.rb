# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SkitteringPrecursor do
  include_context "two player game"

  let!(:precursor) { ResolvePermanent("Skittering Precursor", owner: p1) }

  def spawns(player) = player.creatures.select { _1.name == "Eldrazi Spawn" }

  it "is a devoid 3/3 with menace" do
    expect(precursor.colors).to be_empty
    expect(precursor.power).to eq(3)
    expect(precursor.toughness).to eq(3)
    expect(precursor.has_keyword?(Magic::Cards::Keywords::MENACE)).to be(true)
  end

  it "creates a Spawn when you sacrifice a nontoken permanent" do
    ResolvePermanent("Forest", owner: p1).sacrifice!
    game.settle!

    expect(spawns(p1).count).to eq(1)
  end

  it "does not trigger when you sacrifice a token" do
    precursor.create_eldrazi_spawn
    game.settle!
    spawns(p1).first.sacrifice!
    game.settle!

    expect(spawns(p1).count).to eq(0)
  end

  it "does not trigger when an opponent sacrifices a nontoken permanent" do
    ResolvePermanent("Forest", owner: p2).sacrifice!
    game.settle!

    expect(spawns(p1).count).to eq(0)
  end
end
