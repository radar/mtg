# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ShoreLurker do
  include_context "two player game"

  let!(:lurker) { ResolvePermanent("Shore Lurker", owner: p1) }

  it "is a 3/3 Merfolk Scout with flying" do
    expect(lurker.power).to eq(3)
    expect(lurker.toughness).to eq(3)
    expect(lurker.type?("Merfolk")).to eq(true)
    expect(lurker.type?("Scout")).to eq(true)
    expect(lurker.flying?).to eq(true)
  end

  it "surveils 1 when it enters" do
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(1)
  end

  it "can put the top card into the graveyard" do
    top_card = p1.library.first
    game.resolve_choice!(graveyard: [top_card])
    expect(p1.graveyard.cards).to include(top_card)
  end
end
