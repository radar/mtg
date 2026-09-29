# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Kinbinding do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:kinbinding) { ResolvePermanent("Kinbinding", owner: p1) }

  it "gives your creatures +X/+X, X being the creatures that entered under your control this turn" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!

    expect(p1.creatures.first.power).to eq(3) # X = 1
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!
    expect(p1.creatures.map(&:power)).to all(eq(4)) # X = 2
  end

  it "does not buff an opponent's creatures or count their entries" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect(theirs.power).to eq(2)
  end

  it "resets on the next turn" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    game.tick!
    game.next_turn
    game.next_turn
    go_to_main_phase!
    game.tick!

    expect(p1.creatures.first.power).to eq(2)
  end

  it "creates a 1/1 green and white Kithkin token at the beginning of combat on your turn" do
    current_turn.beginning_of_combat!
    game.settle!
    kithkin = p1.creatures.find { _1.name == "Kithkin" }

    expect(kithkin.colors).to contain_exactly(:green, :white)
  end

  it "does not make a token at the opponent's beginning of combat" do
    game.notify!(Magic::Events::BeginningOfCombat.new(active_player: p2))
    game.settle!

    expect(p1.creatures).to be_empty
  end
end
