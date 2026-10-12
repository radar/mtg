# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ThreatsAroundEveryCorner do
  include_context "two player game"

  before { go_to_main_phase! }

  def face_down = p1.permanents.select(&:face_down?)

  it "manifests dread when it enters, and the manifested creature fetches a basic land" do
    ResolvePermanent("Threats Around Every Corner", owner: p1)
    game.settle!
    game.resolve_choice!(target: game.choices.last.choices.first)
    game.settle!

    # The face-down creature entering triggers the land search
    search = game.choices.last
    expect(search).to be_a(Magic::Choice::SearchLibrary)
    game.resolve_choice!(target: search.choices.first)

    expect(face_down.size).to eq(1)
    expect(p1.lands.size).to eq(1)
    expect(p1.lands.first).to be_tapped
  end

  context "with the enchantment in play" do
    before do
      ResolvePermanent("Threats Around Every Corner", owner: p1)
      game.settle!
      game.resolve_choice!(target: game.choices.last.choices.first)
      game.settle!
      game.resolve_choice!(target: game.choices.last.choices.first)
    end

    it "searches for a basic land whenever another face-down permanent you control enters" do
      game.manifest!(p1.library.first, controller: p1)
      game.settle!

      expect(game.choices.last).to be_a(Magic::Choice::SearchLibrary)
    end

    it "ignores face-down permanents the opponent controls" do
      game.manifest!(p2.library.first, controller: p2)
      game.settle!

      expect(game.choices).to be_empty
    end

    it "ignores face-up permanents entering" do
      ResolvePermanent("Grizzly Bears", owner: p1)
      game.settle!

      expect(game.choices).to be_empty
    end
  end
end
