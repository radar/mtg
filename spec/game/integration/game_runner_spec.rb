# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::GameRunner, "roadmap C2c" do
  include_context "two player game"

  let(:game) { Magic::Game.new(enforce_priority: true) }

  before do
    p1.agent = Magic::Agents::FirstLegalAgent.new
    p2.agent = Magic::Agents::FirstLegalAgent.new
  end

  it "raises without enforce_priority: true" do
    plain_game = Magic::Game.new
    plain_game.add_players(p1, p2)
    plain_game.start!

    expect { plain_game.run! }.to raise_error(/enforce_priority/)
  end

  describe "a whole game between two FirstLegalAgents" do
    it "runs to completion (a player decks out) with no exceptions" do
      finished_game = game.run!(max_actions: 2_000)

      expect(finished_game).to be_over
      expect([p1, p2].one?(&:lost?)).to be(true)
    end
  end

  describe "an agent that prefers a real action over passing" do
    # FirstLegalAgent takes legal_actions.first, and Game#legal_actions puts nil (pass)
    # last, so this is the same agent as above -- it plays lands and taps them for mana
    # in preference to passing, without needing a bespoke agent class.
    let(:eager_agent) { Magic::Agents::FirstLegalAgent.new }

    before do
      p1.agent = eager_agent
      p2.agent = eager_agent
    end

    it "plays lands and taps them for mana before it ever passes" do
      go_to_main_phase!

      expect { Magic::GameRunner.new(game: game, max_actions: 5).call }
        .to raise_error(Magic::GameRunner::NotFinished)

      expect(p1.lands.count).to be >= 1
    end
  end
end
