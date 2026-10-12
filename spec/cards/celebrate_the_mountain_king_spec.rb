# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CelebrateTheMountainKing do
  include_context "two player game"

  # Resolves every pending choice: exile target (if asked) and the recruit discard.
  def settle_choices(exile: nil, discard: nil)
    game.settle!
    10.times do
      choice = game.choices.first
      break unless choice

      case choice
      when Magic::Choice::Targeted then exile ? game.resolve_choice!(target: exile) : game.skip_choice!
      when Magic::Choice::Discard then game.resolve_choice!(card: discard || p1.hand.first)
      else break
      end
      game.settle!
    end
  end

  it "exiles up to one nonland permanent of each opponent until it leaves" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Mountain", owner: p2)
    enchantment = ResolvePermanent("Celebrate The Mountain King", owner: p1)
    settle_choices(exile: bears)

    expect(bears.card.zone).to be_exile

    enchantment.destroy!
    game.settle!

    expect(bears.card.zone).to be_battlefield
  end

  it "doesn't exile a land" do
    land = ResolvePermanent("Mountain", owner: p2)
    ResolvePermanent("Celebrate The Mountain King", owner: p1)
    settle_choices

    expect(p2.permanents).to include(land)
  end

  it "may exile nothing" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    ResolvePermanent("Celebrate The Mountain King", owner: p1)
    settle_choices

    expect(p2.permanents).to include(bears)
  end

  it "recruits: draws, discards, and makes a Human Soldier for a nonland discard" do
    hand = p1.hand.count
    nonland = Card("Grizzly Bears", owner: p1)
    p1.hand.add(nonland)
    ResolvePermanent("Celebrate The Mountain King", owner: p1)
    settle_choices(discard: nonland)

    expect(p1.hand.count).to eq(hand + 1)
    soldiers = p1.creatures.select { _1.token? && _1.type?("Human") && _1.type?("Soldier") }
    expect(soldiers.size).to eq(1)
    expect([soldiers.first.power, soldiers.first.toughness]).to eq([1, 1])
  end

  it "makes no token when the discarded card is a land" do
    land = Card("Plains", owner: p1)
    p1.hand.add(land)
    ResolvePermanent("Celebrate The Mountain King", owner: p1)
    settle_choices(discard: land)

    expect(p1.creatures.select(&:token?)).to be_empty
  end
end
