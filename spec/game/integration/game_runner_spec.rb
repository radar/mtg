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

  describe "restricted mana" do
    let!(:flamebraider) { ResolvePermanent("Flamebraider", owner: p1) }
    let!(:cur) { ResolvePermanent("Igneous Cur", owner: p1) }

    def run_one_action(agent)
      p1.agent = agent
      expect { Magic::GameRunner.new(game: game, max_actions: 1).call }
        .to raise_error(Magic::GameRunner::NotFinished)
    end

    before do
      go_to_main_phase!
      p1.activate_ability(ability: flamebraider.activated_abilities.first) { |a| a.choose(%i[red green]) }
    end

    it "offers an Elemental ability the restricted mana can pay for" do
      candidate = game.legal_actions(p1).find { |a| a.is_a?(Magic::Actions::ActivateAbility) && a.ability.source == cur }

      expect(candidate).not_to be_nil
      expect(candidate.costs.find { |c| c.is_a?(Magic::Costs::Mana) }.can_pay?(p1)).to eq(true)
    end

    it "spends it when the agent activates that ability" do
      candidate = game.legal_actions(p1).find { |a| a.is_a?(Magic::Actions::ActivateAbility) && a.ability.source == cur }
      run_one_action(Magic::Agents::ScriptedAgent.new(answers: [candidate]))

      expect(p1.restricted_mana).to be_empty
    end

    it "does not let generic payment take the mana the colored part of the cost needs" do
      p1.restricted_mana.clear
      p1.add_mana(red: 1, green: 1)
      candidate = game.legal_actions(p1).find { |a| a.is_a?(Magic::Actions::ActivateAbility) && a.ability.source == cur }
      run_one_action(Magic::Agents::ScriptedAgent.new(answers: [candidate]))

      expect(p1.mana_pool.values.sum).to eq(0)
    end

    it "asks for a two-mana combination when the agent taps Flamebraider through the runner" do
      flamebraider.untap!
      tap = game.legal_actions(p1).find { |a| a.is_a?(Magic::Actions::ActivateManaAbility) && a.ability.source == flamebraider }
      run_one_action(Magic::Agents::ScriptedAgent.new(answers: [tap, [:blue]]))

      expect(p1.restricted_mana.map(&:color).tally).to include(blue: 2)
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
