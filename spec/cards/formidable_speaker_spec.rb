# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FormidableSpeaker do
  include_context "two player game"
  before { go_to_main_phase! }

  it "is a 2/4 elf druid" do
    speaker = ResolvePermanent("Formidable Speaker", owner: p1)

    expect(speaker.card.types).to include("Elf", "Druid")
    expect(speaker.power).to eq(2)
    expect(speaker.toughness).to eq(4)
  end

  it "searches for a creature card when a card is discarded" do
    card_to_discard = Card("Forest", owner: p1)
    p1.hand.add(card_to_discard)
    bears = Card("Grizzly Bears", owner: p1)
    p1.library.add(bears)

    ResolvePermanent("Formidable Speaker", owner: p1)
    game.resolve_choice! # accept the "may"
    game.resolve_choice!(card: card_to_discard)
    game.resolve_choice!(targets: [bears])

    expect(bears.zone).to be_hand
  end

  it "does not search when the discard is declined" do
    ResolvePermanent("Formidable Speaker", owner: p1)
    game.skip_choice!

    expect(game.choices).to be_empty
  end

  it "untaps another target permanent for {1}, {T}" do
    speaker = ResolvePermanent("Formidable Speaker", owner: p1)
    game.skip_choice! # decline the ETB's "may discard" choice, unrelated to this ability
    forest = ResolvePermanent("Forest", owner: p1)
    forest.tap!
    p1.add_mana(green: 1)

    p1.activate_ability(ability: speaker.activated_abilities.first, auto_tap: true) { |a| a.pay_mana(generic: { green: 1 }).targeting(forest) }
    game.stack.resolve!

    expect(forest).not_to be_tapped
  end
end
