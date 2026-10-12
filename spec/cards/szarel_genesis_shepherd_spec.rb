require "spec_helper"

RSpec.describe Magic::Cards::SzarelGenesisShepherd do
  include_context "two player game"

  it "is legendary and flying" do
    shepherd = ResolvePermanent("Szarel, Genesis Shepherd", owner: p1)

    expect(shepherd).to be_legendary
    expect(shepherd).to be_flying
  end

  context "playing lands from the graveyard" do
    let!(:shepherd) { ResolvePermanent("Szarel, Genesis Shepherd", owner: p1) }
    let(:forest) { Card("Forest", owner: p1) }

    before do
      go_to_main_phase!
      p1.graveyard.add(forest)
    end

    it "lets its controller play a land from their graveyard" do
      p1.play_land(land: forest)

      expect(p1.permanents.map(&:name)).to include("Forest")
      expect(p1.graveyard.cards).not_to include(forest)
    end

    it "doesn't let the opponent play lands from their graveyard" do
      mountain = Card("Mountain", owner: p2)
      p2.graveyard.add(mountain)
      action = Magic::Actions::PlayLand.new(game: game, player: p2, card: mountain)

      expect(action.illegal_reason).to match(/not in a zone/)
    end
  end
end