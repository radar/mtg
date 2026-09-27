# frozen_string_literal: true

require "spec_helper"

# Roadmap L2: play whole games with FirstLegalAgent driving both players and assert
# invariants that should hold no matter what happened during the game. Scoped down from
# the full roadmap item -- there's no seeded RNG or random deck yet (needs H2), so this
# runs a handful of fixed, varied decks instead of truly random ones. Any crash here (an
# unhandled exception from Game#run!) is exactly the kind of bug report L2 exists to
# produce; the invariant checks below catch state corruption that wouldn't otherwise
# raise anything.
RSpec.describe "Self-play (roadmap L2)" do
  include_context "two player game"

  let(:game) { Magic::Game.new(enforce_priority: true) }

  before do
    p1.agent = Magic::Agents::FirstLegalAgent.new
    p2.agent = Magic::Agents::FirstLegalAgent.new
  end

  # deck_size is the number of cards +player+ started with (its whole library, since
  # nothing outside the shared context puts anything in their hand beforehand) -- every
  # one of those cards must still be found in exactly one zone or on the battlefield.
  def assert_invariants!(player:, deck_size:)
    expect(game.stack).to be_empty
    expect(player.life).to be > 0 unless player.lost?

    on_battlefield = game.battlefield.permanents.controlled_by(player).nontoken.map(&:card)
    all_cards = player.hand.cards + player.library.cards + player.graveyard.cards + player.exile.cards + on_battlefield
    expect(all_cards.uniq.size).to eq(all_cards.size), "found a duplicated card for #{player.inspect}"
    expect(all_cards.size).to eq(deck_size), "expected #{deck_size} cards for #{player.inspect}, found #{all_cards.size}"
  end

  shared_examples "plays a full game with no exceptions and no corrupted state" do
    it "runs to completion" do
      p1_deck_size = p1_library.size
      p2_deck_size = p2_library.size

      finished_game = nil
      expect { finished_game = game.run!(max_actions: 5_000) }.not_to raise_error

      expect(finished_game).to be_over
      assert_invariants!(player: p1, deck_size: p1_deck_size)
      assert_invariants!(player: p2, deck_size: p2_deck_size)
    end
  end

  context "an all-land deck (mana abilities and land plays only, no spells)" do
    let(:p1_library) { 14.times.map { Card("Forest") } }
    let(:p2_library) { 14.times.map { Card("Mountain", owner: p2) } }

    include_examples "plays a full game with no exceptions and no corrupted state"
  end

  context "a creature deck (vanilla creatures, combat, attacking/blocking)" do
    let(:p1_library) { 7.times.map { Card("Forest") } + 7.times.map { Card("Grizzly Bears") } }
    let(:p2_library) { 7.times.map { Card("Forest", owner: p2) } + 7.times.map { Card("Grizzly Bears", owner: p2) } }

    include_examples "plays a full game with no exceptions and no corrupted state"
  end

  context "a mixed deck (creatures, a single-target burn spell, two colors)" do
    let(:p1_library) do
      5.times.map { Card("Forest") } + 5.times.map { Card("Mountain") } +
        4.times.map { Card("Grizzly Bears") } + 4.times.map { Card("Lightning Bolt") }
    end
    let(:p2_library) do
      5.times.map { Card("Forest", owner: p2) } + 5.times.map { Card("Mountain", owner: p2) } +
        4.times.map { Card("Grizzly Bears", owner: p2) } + 4.times.map { Card("Lightning Bolt", owner: p2) }
    end

    include_examples "plays a full game with no exceptions and no corrupted state"
  end
end
