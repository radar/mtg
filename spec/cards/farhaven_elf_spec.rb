# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::FarhavenElf do
  include_context "two player game"

  it "is a 1/1 Elf Druid" do
    elf = ResolvePermanent("Farhaven Elf", owner: p1)
    expect(elf.power).to eq(1)
    expect(elf.toughness).to eq(1)
    expect(elf.type?("Elf")).to be true
  end

  it "may search the library for a basic land and put it onto the battlefield tapped" do
    ResolvePermanent("Farhaven Elf", owner: p1)

    choice = game.choices.last
    expect(choice).to be_a(described_class::MaySearchChoice)

    game.resolve_choice!
    search_choice = game.choices.last
    expect(search_choice).to be_a(described_class::SearchChoice)

    forest = search_choice.choices.first
    game.resolve_choice!(targets: [forest])

    expect(forest.zone).to be_battlefield
    expect(game.battlefield.by_card(forest).first).to be_tapped
  end

  it "does not search when declined" do
    ResolvePermanent("Farhaven Elf", owner: p1)

    lands_before = p1.lands.count
    game.skip_choice!

    expect(p1.lands.count).to eq(lands_before)
  end
end
