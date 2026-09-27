# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SurlyFarrier do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:farrier) { ResolvePermanent("Surly Farrier", owner: p1) }

  it "is a 2/2 kithkin citizen" do
    expect(farrier.card.types).to include("Kithkin", "Citizen")
    expect(farrier.power).to eq(2)
    expect(farrier.toughness).to eq(2)
  end

  it "gives target creature you control +1/+1 and vigilance until end of turn for {T}" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)

    p1.activate_ability(ability: farrier.activated_abilities.first) { |a| a.targeting(bears) }
    game.stack.resolve!

    expect(bears.power).to eq(3)
    expect(bears.toughness).to eq(3)
    expect(bears).to have_keyword(:vigilance)
  end

  it "can only be activated as a sorcery" do
    current_turn.beginning_of_combat!

    expect { p1.activate_ability(ability: farrier.activated_abilities.first) { |a| a.targeting(farrier) } }
      .to raise_error(Magic::IllegalAction)
  end
end
