# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PiercingExhale do
  include_context "two player game"

  let(:card) { Card("Piercing Exhale", owner: p1) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { p1.add_mana(green: 2) }

  it "has your creature deal damage equal to its power to the target, one way" do
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 1 }, green: 1).targeting(mine, theirs) }
    game.stack.resolve!
    game.settle!
    expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    expect(mine.damage).to eq(0)
    expect(game.choices).to be_empty
  end

  it "surveils 2 if a Dragon was beheld" do
    dragon = ResolvePermanent("Adult Gold Dragon", owner: p1)
    p1.cast(card: card) { |a| a.pay_mana(generic: { green: 1 }, green: 1).pay_kicker(dragon).targeting(mine, theirs) }
    game.stack.resolve!
    expect(game.choices.last).to be_a(Magic::Choice::Surveil)
    expect(game.choices.last.amount).to eq(2)
  end
end
