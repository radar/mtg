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
