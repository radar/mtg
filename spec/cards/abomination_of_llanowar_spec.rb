# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::AbominationOfLlanowar do
  include_context "two player game"

  subject { ResolvePermanent("Abomination Of Llanowar", owner: p1) }

  it "is a legendary Elf Horror with vigilance and menace" do
    expect(subject.type?("Elf")).to be true
    expect(subject.type?("Horror")).to be true
    expect(subject).to have_keyword(:vigilance)
    expect(subject).to have_keyword(:menace)
  end

  it "has power and toughness equal to the Elves you control plus Elf cards in your graveyard" do
    game.tick!
    expect(subject.power).to eq(1)
    expect(subject.toughness).to eq(1)

    ResolvePermanent("Llanowar Elves", owner: p1)
    game.tick!
    expect(subject.power).to eq(2)
    expect(subject.toughness).to eq(2)
  end

  it "counts Elf cards in the controller's graveyard" do
    Card("Llanowar Elves", owner: p1).move_to_graveyard!(p1)
    game.tick!

    expect(subject.power).to eq(2)
    expect(subject.toughness).to eq(2)
  end

  it "does not count an opponent's Elves" do
    ResolvePermanent("Llanowar Elves", owner: p2)
    game.tick!

    expect(subject.power).to eq(1)
  end
end
