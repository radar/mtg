# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChangelingWayfinder do
  include_context "two player game"

  it "is a 1/2 with every creature type" do
    creature = ResolvePermanent("Changeling Wayfinder", owner: p1, settle: false)
    expect(creature.power).to eq(1)
    expect(creature.toughness).to eq(2)
    expect(creature.type?("Shapeshifter")).to be true
    expect(creature.type?("Elf")).to be true
    expect(creature.type?("Goblin")).to be true
  end

  it "has every creature type in hand too (rule 702.73a)" do
    card = Card("Changeling Wayfinder", owner: p1)
    expect(card.type?("Elf")).to be true
    expect(card.type?("Shapeshifter")).to be true
  end

  it "may search the library for a basic land and put it into hand" do
    ResolvePermanent("Changeling Wayfinder", owner: p1)

    expect(game.choices.last).to be_a(described_class::MaySearchChoice)
    game.resolve_choice!
    search_choice = game.choices.last
    expect(search_choice).to be_a(described_class::SearchChoice)

    forest = search_choice.choices.first
    game.resolve_choice!(targets: [forest])

    expect(forest.zone).to be_hand
    expect(p1.hand).to include(forest)
  end

  it "does not search when declined" do
    ResolvePermanent("Changeling Wayfinder", owner: p1)
    hand_before = p1.hand.count
    game.skip_choice!
    expect(p1.hand.count).to eq(hand_before)
  end
end
