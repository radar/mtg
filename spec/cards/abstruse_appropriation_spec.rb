# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AbstruseAppropriation do
  include_context "two player game"

  let(:card) { Card("Abstruse Appropriation", owner: p1) }
  let!(:dreadmaw) { ResolvePermanent("Colossal Dreadmaw", owner: p2) }
  let!(:land) { ResolvePermanent("Forest", owner: p2) }

  before do
    go_to_main_phase!
    p1.hand.add(card)
    p1.add_mana(white: 1, black: 1, red: 2)
  end

  def cast_appropriation
    p1.cast(card:) { |action| action.pay_mana(white: 1, black: 1, generic: { red: 2 }).targeting(dreadmaw) }
    game.stack.resolve!
    game.settle!
  end

  it "is colorless" do
    expect(card.colors).to be_empty
  end

  it "exiles a nonland permanent" do
    cast_appropriation

    expect(game.exile.cards.map(&:name)).to include("Colossal Dreadmaw")
  end

  it "lets the caster cast the exiled card using colorless mana as any colour" do
    cast_appropriation
    exiled = game.exile.cards.find { _1.name == "Colossal Dreadmaw" }
    expect(exiled).not_to be_nil

    p1.add_mana(colorless: 6)
    p1.cast(card: exiled) { |action| action.pay_mana(generic: { colorless: 4 }, colorless: 2) }
    game.stack.resolve!

    expect(p1.creatures.map(&:name)).to include("Colossal Dreadmaw")
  end
end
