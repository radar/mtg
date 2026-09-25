# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LysAlanaInformant do
  include_context "two player game"

  let!(:informant) { ResolvePermanent("Lys Alana Informant", owner: p1) }

  it "is a 3/1 Elf Scout" do
    expect(informant.power).to eq(3)
    expect(informant.toughness).to eq(1)
    expect(informant.type?("Elf")).to eq(true)
    expect(informant.type?("Scout")).to eq(true)
  end

  it "surveils 1 when it enters" do
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(1)
  end

  it "can put the top card into the graveyard when it enters" do
    top_card = p1.library.first
    game.resolve_choice!(graveyard: [top_card])
    expect(p1.graveyard.cards).to include(top_card)
  end

  it "surveils 1 when it dies" do
    game.resolve_choice!(top: p1.library.first(1))
    informant.destroy!
    game.settle!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(1)
  end
end
