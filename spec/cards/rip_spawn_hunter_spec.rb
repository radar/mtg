# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RipSpawnHunter do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:rip) { ResolvePermanent("Rip, Spawn Hunter", owner: p1) }
  let!(:twin_bears) { add_to_library("Grizzly Bears", player: p1) }
  let!(:bears) { add_to_library("Grizzly Bears", player: p1) }
  let!(:angel) { add_to_library("Serra Angel", player: p1) }
  let!(:forest) { add_to_library("Forest", player: p1) }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a legendary 4/4 Human Survivor" do
    expect([rip.power, rip.toughness]).to eq([4, 4])
    expect(rip.card.types).to include("Human", "Survivor")
    expect(rip.card).to be_legendary
  end

  context "when tapped at the second main phase" do
    before do
      rip.tap!
      to_second_main!
    end

    it "offers only creature cards among the top four" do
      expect(game.choices.first.choices).to contain_exactly(angel, bears, twin_bears)
    end

    it "puts chosen creatures with different powers into hand and the rest on the bottom" do
      game.resolve_choice!(targets: [angel, bears])
      game.settle!

      expect(p1.hand.cards).to include(angel, bears)
      expect(p1.library.cards).not_to include(angel, bears)
      expect(p1.library.cards.last(2)).to contain_exactly(forest, twin_bears)
    end

    it "rejects creatures that share a power" do
      expect { game.resolve_choice!(targets: [bears, twin_bears]) }.to raise_error(ArgumentError, /different powers/)
    end
  end

  it "does nothing if untapped" do
    to_second_main!

    expect(game.choices).to be_empty
  end
end
