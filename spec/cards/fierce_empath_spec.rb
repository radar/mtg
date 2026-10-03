# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FierceEmpath do
  include_context "two player game"

  let!(:big) { Card("Rune-Scarred Demon", owner: p1).tap { p1.library.add(_1) } }
  let!(:small) { Card("Grizzly Bears", owner: p1).tap { p1.library.add(_1) } }
  let!(:spell) { Card("Lightning Bolt", owner: p1).tap { p1.library.add(_1) } }

  it "is a 1/1 Elf" do
    empath = ResolvePermanent("Fierce Empath", owner: p1, settle: false)

    expect([empath.power, empath.toughness]).to eq([1, 1])
    expect(empath.type?("Elf")).to be(true)
  end

  it "may search for a creature card with mana value 6 or greater and put it into your hand" do
    ResolvePermanent("Fierce Empath", owner: p1)
    game.settle!
    game.resolve_choice!
    search = game.choices.last

    expect(search.choices.to_a).to contain_exactly(big)
    game.resolve_choice!(targets: [big])

    expect(p1.hand).to include(big)
    expect(p1.library).not_to include(big)
  end

  it "does not offer creatures with a lower mana value or noncreature cards" do
    ResolvePermanent("Fierce Empath", owner: p1)
    game.settle!
    game.resolve_choice!
    search = game.choices.last

    expect(search.choices.to_a).not_to include(small, spell)
  end

  it "searches nothing when declined" do
    ResolvePermanent("Fierce Empath", owner: p1)
    game.settle!
    hand_size = p1.hand.count
    game.skip_choice!

    expect(p1.hand.count).to eq(hand_size)
    expect(p1.library).to include(big)
  end
end
