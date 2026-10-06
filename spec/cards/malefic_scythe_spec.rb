# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MaleficScythe do
  include_context "two player game"

  let!(:scythe) { ResolvePermanent("Malefic Scythe", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "enters with a soul counter" do
    expect(scythe.counters.of_type(Magic::Counters::Soul).count).to eq(1)
  end

  it "gives the equipped creature +1/+1 for each soul counter" do
    scythe.attach_to!(bears)
    game.tick!
    expect([bears.power, bears.toughness]).to eq([3, 3])

    scythe.add_counter(Magic::Counters::Soul)
    game.tick!
    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "gets a soul counter whenever the equipped creature dies" do
    scythe.attach_to!(bears)
    game.tick!
    bears.destroy!
    game.settle!

    expect(scythe.counters.of_type(Magic::Counters::Soul).count).to eq(2)
  end

  it "ignores other creatures dying" do
    scythe.attach_to!(bears)
    ResolvePermanent("Grizzly Bears", owner: p2).destroy!
    game.settle!

    expect(scythe.counters.of_type(Magic::Counters::Soul).count).to eq(1)
  end
end
