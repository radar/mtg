# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WolverineRiders do
  include_context "two player game"

  let!(:riders) { ResolvePermanent("Wolverine Riders", owner: p1) }

  it "is a 4/4 Elf Warrior" do
    expect(riders.power).to eq(4)
    expect(riders.toughness).to eq(4)
    expect(riders.type?("Elf")).to be true
  end

  it "creates a 1/1 green Elf Warrior token at the beginning of each upkeep" do
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
    game.settle!

    tokens = p1.creatures.select { |c| c.name == "Elf Warrior" && c.token? }
    expect(tokens.count).to eq(1)
  end

  it "also triggers on the opponent's upkeep" do
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
    game.settle!

    tokens = p1.creatures.select { |c| c.name == "Elf Warrior" && c.token? }
    expect(tokens.count).to eq(1)
  end

  it "gains life equal to the toughness of another Elf you control that enters" do
    expect { ResolvePermanent("Grizzly Bears", owner: p1) }.not_to change { p1.life }

    expect { ResolvePermanent("Llanowar Elves", owner: p1) }.to change { p1.life }.by(1)
  end

  it "does not gain life for an opponent's Elf entering" do
    expect { ResolvePermanent("Llanowar Elves", owner: p2) }.not_to change { p1.life }
  end
end
