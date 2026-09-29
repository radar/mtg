# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated modal spells with qualified targets in play" do
  include CardParserHelpers
  include_context "two player game"

  let(:charm) { Card("Parsed Snare", owner: p1) }

  def cast_mode(index, target = nil)
    p1.hand.add(charm)
    p1.add_mana(white: 2)
    p1.cast(card: charm) do |action|
      action.choose_mode(charm.modes[index]) { |mode| mode.targeting(target) if target }
      action.pay_mana(generic: { white: 1 }, white: 1)
    end
    game.stack.resolve!
  end

  before do
    load_card("Parsed Snare {1}{W}\nInstant\nChoose one —\n• Parsed Snare deals 4 damage to target tapped creature.\n" \
              "• Destroy target creature with flying.\n• Destroy target creature with mana value 3 or greater.\n" \
              "• Destroy target artifact or enchantment.\n")
  end

  it "deals damage only to a tapped creature" do
    tapped = ResolvePermanent("Courser Of Kruphix", owner: p2)
    tapped.tap!
    untapped = ResolvePermanent("Courser Of Kruphix", owner: p2)

    expect(charm.modes[0].new(game:, card: charm).target_choices).to include(tapped)
    expect(charm.modes[0].new(game:, card: charm).target_choices).not_to include(untapped)
  end

  it "destroys a creature with flying" do
    flyer = ResolvePermanent("Shinestriker", owner: p2)
    game.tick!
    cast_mode(1, flyer)

    expect(flyer.card.zone).to be_graveyard
  end

  it "only offers creatures with mana value 3 or greater" do
    big = ResolvePermanent("Courser Of Kruphix", owner: p2)
    small = ResolvePermanent("Grizzly Bears", owner: p2)
    choices = charm.modes[2].new(game:, card: charm).target_choices

    expect(choices).to include(big)
    expect(choices).not_to include(small)
  end

  it "destroys an artifact or an enchantment" do
    stone = ResolvePermanent("Mind Stone", owner: p2)
    cast_mode(3, stone)

    expect(stone.card.zone).to be_graveyard
  end
end

RSpec.describe "CardParser generated modal enters trigger in play" do
  include CardParserHelpers
  include_context "two player game"

  before do
    load_card("Parsed Mite {2}{U}\nCreature — Faerie Rogue\nFlash\nFlying\nWhen ~ enters, choose one —\n" \
              "• Tap target creature.\n• Untap target creature.\n2/2\n")
  end

  it "asks which mode, then for the target of that mode" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Parsed Mite", owner: p1)

    expect(game.choices.last.choices).to eq([0, 1])
    game.resolve_choice!(mode: 0)
    game.resolve_choice!(target: bears)

    expect(bears).to be_tapped
  end

  it "runs the other mode when it is chosen" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    bears.tap!
    ResolvePermanent("Parsed Mite", owner: p1)

    game.resolve_choice!(mode: 1)
    game.resolve_choice!(target: bears)

    expect(bears).not_to be_tapped
  end
end

RSpec.describe "CardParser generated \"target player\" modes in play" do
  include CardParserHelpers
  include_context "two player game"
  before { go_to_main_phase! }

  let(:charm) { Card("Parsed Gift", owner: p1) }

  before do
    load_card("Parsed Gift {1}{G}\nInstant\nChoose one —\n• Target player draws two cards.\n" \
              "• Target player creates two Treasure tokens.\n• Target player creates a 1/1 green and white Kithkin creature token.\n")
  end

  def cast_mode(index, target)
    p1.hand.add(charm)
    p1.add_mana(green: 2)
    p1.cast(card: charm) do |action|
      action.choose_mode(charm.modes[index]) { |mode| mode.targeting(target) }
      action.pay_mana(generic: { green: 1 }, green: 1)
    end
    game.stack.resolve!
  end

  it "makes the targeted player draw" do
    expect { cast_mode(0, p2) }.to change { p2.hand.count }.by(2)
  end

  it "gives the targeted player Treasures" do
    cast_mode(1, p2)

    expect(p2.permanents.count { _1.name == "Treasure" }).to eq(2)
  end

  it "gives the targeted player a Kithkin token" do
    cast_mode(2, p2)

    expect(p2.creatures.map(&:name)).to eq(["Kithkin"])
  end
end
