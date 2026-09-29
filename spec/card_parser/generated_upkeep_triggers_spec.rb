# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

# Upkeep triggers (roadmap L1b): "sacrifice ~ unless you pay ...", named counters on ~,
# untargeted damage to you / each creature and player, and an intervening "if".
RSpec.describe "CardParser generated upkeep triggers in play" do
  include CardParserHelpers
  include_context "two player game"

  # Stops at the beginning of p1's upkeep, with its triggers resolved (choices pending).
  def upkeep!
    current_turn.untap!
    current_turn.upkeep!
  end

  # p1's next turn again (p2 has one in between).
  def next_own_turn! = 2.times { game.next_turn }

  describe "sacrifice ~ unless you pay" do
    let(:text) { "Parsed Pact {W}{W}\nEnchantment\nAt the beginning of your upkeep, sacrifice ~ unless you pay {W}{W}.\n" }
    let!(:pact) { load_card(text) && ResolvePermanent("Parsed Pact", owner: p1) }

    it "parses to a Choice::UnlessPay" do
      expect(generate(text)).to include("Magic::Choice::UnlessPay").and include('penalty: :sacrifice, mana: "{W}{W}"')
    end

    it "keeps the permanent when the mana is paid, spending it" do
      upkeep!
      p1.add_mana(white: 2)
      expect(game.choices.first).to be_a(Magic::Choice::UnlessPay)
      game.resolve_choice!
      expect(pact.zone).to be_battlefield
      expect(p1.mana_pool[:white]).to eq(0)
    end

    it "sacrifices the permanent when declined" do
      upkeep!
      game.skip_choice!
      game.settle!
      expect(pact.card.zone).to be_graveyard
    end

    it "sacrifices the permanent when the player can't pay" do
      upkeep!
      game.resolve_choice!
      game.settle!
      expect(pact.card.zone).to be_graveyard
    end
  end

  it "taps ~ unless you pay life" do
    load_card("Parsed Idol {2}\nArtifact\nAt the beginning of your upkeep, tap ~ unless you pay 2 life.\n")
    idol = ResolvePermanent("Parsed Idol", owner: p1)
    upkeep!
    game.resolve_choice!
    expect(idol).to be_untapped
    expect(p1.life).to eq(18)

    next_own_turn!
    upkeep!
    game.skip_choice!
    expect(idol).to be_tapped
    expect(p1.life).to eq(18)
  end

  it "sacrifices ~ unless you discard a card, choosing which" do
    load_card("Parsed Toll {1}{B}\nEnchantment\nAt the beginning of your upkeep, sacrifice ~ unless you discard a card.\n")
    toll = ResolvePermanent("Parsed Toll", owner: p1)
    upkeep!
    card = p1.hand.cards.first
    game.resolve_choice!(payment: card)
    expect(card.zone).to be_graveyard
    expect(toll.zone).to be_battlefield
  end

  it "sacrifices ~ unless you sacrifice a creature" do
    load_card("Parsed Altar {1}{B}\nEnchantment\nAt the beginning of your upkeep, sacrifice ~ unless you sacrifice a creature.\n")
    altar = ResolvePermanent("Parsed Altar", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    upkeep!
    game.resolve_choice!(payment: bears)
    expect(bears.card.zone).to be_graveyard
    expect(altar.zone).to be_battlefield
  end

  describe "named counters on ~" do
    it "adds a spore counter each upkeep and removes it again" do
      load_card("Parsed Bloom {G}\nEnchantment\nAt the beginning of your upkeep, put a spore counter on ~.\n" \
                "At the beginning of your end step, remove a spore counter from ~.\n")
      bloom = ResolvePermanent("Parsed Bloom", owner: p1)
      go_to_main_phase!
      expect(bloom.counters.of_type(Magic::Counters::Spore).count).to eq(1)
      current_turn.end!
      expect(bloom.counters.of_type(Magic::Counters::Spore).count).to eq(0)
    end

    it "makes a class for any single-word counter, once, but not for other shapes" do
      expect(Magic::Counters["age"]).to eq(Magic::Counters::Age)
      expect(Magic::Counters["age"]).to equal(Magic::Counters["age"])
      expect(Magic::Counters::Wibble).to equal(Magic::Counters["wibble"])
      expect { Magic::Counters::Wibble2 }.to raise_error(NameError)
      expect { Magic::Counters["+2/+2"] }.to raise_error(/Unknown counter type/)
      expect { Magic::Counters["collection"] }.to raise_error(/Unknown counter type/)
    end
  end

  describe "untargeted damage" do
    it "deals damage to you" do
      load_card("Parsed Brand {R}\nEnchantment\nAt the beginning of your upkeep, ~ deals 1 damage to you.\n")
      ResolvePermanent("Parsed Brand", owner: p1)
      go_to_main_phase!
      expect(p1.life).to eq(19)
      expect(p2.life).to eq(20)
    end

    it "deals damage to each creature and each player" do
      load_card("Parsed Storm {2}{R}\nEnchantment\nAt the beginning of your upkeep, ~ deals 1 damage to each creature and each player.\n")
      ResolvePermanent("Parsed Storm", owner: p1)
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      go_to_main_phase!
      game.settle!
      expect([p1.life, p2.life]).to eq([19, 19])
      expect(bears.damage).to eq(1)
    end
  end

  describe "an intervening if" do
    before do
      load_card("Parsed Sanctuary {1}{W}\nEnchantment\nAt the beginning of your upkeep, if you have 5 or less life, you gain 3 life.\n")
      ResolvePermanent("Parsed Sanctuary", owner: p1)
    end

    it "does nothing while the condition is false" do
      go_to_main_phase!
      expect(p1.life).to eq(20)
    end

    it "acts when the condition is true, and not in the opponent's upkeep" do
      p1.lose_life(15)
      go_to_main_phase!
      expect(p1.life).to eq(8)

      game.next_turn
      go_to_main_phase!
      expect(p1.life).to eq(8)
    end
  end

  it "checks a counter threshold on ~ in an intervening if" do
    load_card("Parsed Hive {2}{G}\nEnchantment\nAt the beginning of your upkeep, if ~ has two or more spore counters on it, you gain 2 life.\n")
    hive = ResolvePermanent("Parsed Hive", owner: p1)
    hive.add_counter("spore", amount: 2)
    go_to_main_phase!
    expect(p1.life).to eq(22)
  end
end
