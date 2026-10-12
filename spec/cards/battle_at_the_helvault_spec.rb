require "spec_helper"

RSpec.describe Magic::Cards::BattleAtTheHelvault do
  include_context "two player game"

  let(:saga) { ResolvePermanent("Battle At The Helvault", owner: p1) }

  def battlefield_names = game.battlefield.permanents.map(&:name)

  it "enters with a lore counter" do
    expect(saga.counters.of_type(Magic::Counters::Lore).count).to eq(1)
  end

  describe "chapters I and II" do
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Wood Elves", owner: p2) }
    let!(:their_land) { ResolvePermanent("Forest", owner: p2) }

    # The Saga enters last: its chapter I triggers as it enters, so everything it could exile must already be there.
    before do
      saga
      game.settle!
    end

    it "asks about each player in turn, starting with the Saga's controller, for a nonland non-Saga permanent" do
      choices = game.choices.to_a

      expect(choices.map(&:class).uniq).to eq([described_class::ExileChoice])
      expect(choices.map(&:victim)).to eq([p1, p2])
      expect(choices.first.choices).to match_array([mine])
      expect(choices.last.choices).to match_array([theirs])
    end

    it "says whose permanents each choice shows" do
      prompts = game.choices.to_a.map(&:prompt)

      expect(prompts.first).to include("your permanents")
      expect(prompts.last).to include("#{p2.name}'s permanents")
    end

    it "exiles what is chosen, and only until the Saga leaves" do
      game.resolve_choice!(target: mine)
      game.resolve_choice!(target: theirs)

      expect(battlefield_names).to include("Forest", "Battle at the Helvault")
      expect(battlefield_names).not_to include("Grizzly Bears", "Wood Elves")

      saga.sacrifice!
      game.settle!

      expect(battlefield_names).to include("Grizzly Bears", "Wood Elves")
    end

    it "exiles a token for good" do
      token = Magic::Cards::SigilOfTheEmptyThrone::AngelToken.new(game: game, owner: p2).resolve!
      game.resolve_choice!(target: nil)
      game.resolve_choice!(target: token)

      expect(game.battlefield.permanents).not_to include(token)

      saga.sacrifice!
      game.settle!

      expect(game.battlefield.permanents.map(&:name)).not_to include("Angel")
    end

    it "can exile nothing" do
      game.skip_choice!
      game.skip_choice!

      expect(battlefield_names).to include("Grizzly Bears", "Wood Elves")
    end
  end
end
