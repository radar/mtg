# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser planeswalkers" do
  include CardParserHelpers
  include_context "two player game"

  let(:text) do
    "Parsed Walker {2}{B}\nLegendary Planeswalker — Walker\n" \
      "+1: Draw a card. You lose 1 life.\n" \
      "−2: Destroy target creature.\n" \
      "0: You gain 2 life.\n" \
      "−6: Each opponent loses 6 life.\n" \
      "Loyalty: 4\n"
  end

  before do
    load_card(text)
    go_to_main_phase!
  end

  subject(:walker) { Magic::Permanent.resolve(game: game, owner: p1, card: Card("Parsed Walker", owner: p1)) }

  it "generates a Planeswalker subclass with its loyalty and abilities" do
    source = generate(text)
    expect(source).to include("class ParsedWalker < Planeswalker", 'card_name "Parsed Walker"', 'planeswalker "Walker"',
                              "cost generic: 2, black: 1", "loyalty 4", "def loyalty_change = 1", "def loyalty_change = -2",
                              "def loyalty_change = 0", "def loyalty_change = -6",
                              "def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3, LoyaltyAbility4]")
  end

  it "enters with its printed loyalty" do
    expect(walker.loyalty).to eq(4)
  end

  it "runs a plus ability" do
    hand_size = p1.hand.count
    p1.activate_loyalty_ability(ability: walker.loyalty_abilities[0])
    game.stack.resolve!

    expect(walker.loyalty).to eq(5)
    expect(p1.hand.count).to eq(hand_size + 1)
    expect(p1.life).to eq(19)
  end

  it "runs a minus ability with a target" do
    bear = ResolvePermanent("Grizzly Bears", owner: p2)
    p1.activate_loyalty_ability(ability: walker.loyalty_abilities[1]) { _1.targeting(bear) }
    game.stack.resolve!
    game.tick!

    expect(walker.loyalty).to eq(2)
    expect(bear.card.zone).to be_graveyard
  end

  it "runs a zero ability" do
    p1.activate_loyalty_ability(ability: walker.loyalty_abilities[2])
    game.stack.resolve!

    expect(walker.loyalty).to eq(4)
    expect(p1.life).to eq(22)
  end

  it "refuses an ability it can't afford" do
    expect { p1.activate_loyalty_ability(ability: walker.loyalty_abilities[3]) }.to raise_error(Magic::IllegalAction, /enough loyalty/)
  end

  it "reads hyphen and en-dash minus signs" do
    source = generate("Dash Walker {3}\nLegendary Planeswalker — Dash\n-1: You gain 1 life.\n–2: You gain 2 life.\nLoyalty: 3\n")
    expect(source).to include("def loyalty_change = -1", "def loyalty_change = -2")
  end

  it "needs a loyalty line and a loyalty ability" do
    expect { generate("Bare Walker {3}\nLegendary Planeswalker — Bare\n+1: You gain 1 life.\n") }
      .to raise_error(Magic::CardParser::ParseError, /Loyalty/)
    expect { generate("Idle Walker {3}\nLegendary Planeswalker — Idle\nLoyalty: 3\n") }
      .to raise_error(Magic::CardParser::ParseError, /LoyaltyAbility/)
  end

  it "rejects non-legendary planeswalkers and X abilities" do
    expect { generate("Plain Walker {3}\nPlaneswalker — Plain\n+1: You gain 1 life.\nLoyalty: 3\n") }
      .to raise_error(Magic::CardParser::UnsupportedCard, /non-legendary/)
    expect { generate("X Walker {3}\nLegendary Planeswalker — X\n−X: You gain 1 life.\nLoyalty: 3\n") }
      .to raise_error(Magic::CardParser::UnsupportedCard)
  end

  it "keeps static abilities alongside loyalty abilities" do
    source = generate("Anthem Walker {3}{W}\nLegendary Planeswalker — Anthem\nCreatures you control get +1/+1.\n" \
                      "+1: You gain 1 life.\nLoyalty: 4\n")
    expect(source).to include("def static_abilities", "def loyalty_abilities")
  end
end
