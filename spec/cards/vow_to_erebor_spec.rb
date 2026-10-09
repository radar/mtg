# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::VowToErebor do
  include_context "two player game"

  let(:card) { Card("Vow To Erebor", owner: p1) }

  before do
    p1.hand.add(card)
    p1.add_mana(white: 2)
  end

  def cast_on(creature)
    p1.cast(card:) { |a| a.pay_mana(generic: { white: 1 }, white: 1).targeting(creature) }
    game.stack.resolve!
    game.tick!
  end

  it "untaps the creature and gives it +2/+2" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    bears.tap!
    cast_on(bears)

    expect(bears).not_to be_tapped
    expect([bears.power, bears.toughness]).to eq([4, 4])
  end

  it "does not offer an attach for a non-Dwarf" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    spatula = ResolvePermanent("Well-Worn Spatula", owner: p1)
    cast_on(bears)

    expect(game.choices).to be_empty
    expect(spatula.attached_to).to be_nil
  end

  it "lets you attach an Equipment to a Dwarf" do
    dwarf = ResolvePermanent("Dáin's Company", owner: p1)
    game.skip_choice! # its own enters trigger
    ResolvePermanent("Well-Worn Spatula", owner: p1)
    other = ResolvePermanent("Well-Worn Spatula", owner: p1)
    cast_on(dwarf)
    game.resolve_choice!(target: other)
    game.tick!

    expect(dwarf.attachments).to include(other)
  end

  it "may decline the attach" do
    dwarf = ResolvePermanent("Dáin's Company", owner: p1)
    game.skip_choice! # its own enters trigger
    ResolvePermanent("Well-Worn Spatula", owner: p1)
    cast_on(dwarf)
    expect(game.choices.last).to be_a(described_class::AttachChoice)
    game.skip_choice!

    expect(dwarf.attachments).to be_empty
  end
end
