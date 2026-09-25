# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WaryFarmer do
  include_context "two player game"

  let!(:farmer) { ResolvePermanent("Wary Farmer", owner: p1) }

  def surveil_choices = game.choices.select { _1.is_a?(Magic::Choice::Surveil) }

  before { go_to_main_phase! }

  it "is a 3/3 Kithkin Citizen" do
    expect(farmer.power).to eq(3)
    expect(farmer.toughness).to eq(3)
    expect(farmer.type?("Kithkin")).to eq(true)
    expect(farmer.type?("Citizen")).to eq(true)
  end

  it "surveils 1 at your end step if another creature entered under your control this turn" do
    ResolvePermanent("Grizzly Bears", owner: p1)
    current_turn.end!

    choice = surveil_choices.first
    expect(choice).not_to be_nil
    expect(choice.amount).to eq(1)
  end

  it "doesn't surveil if no other creature entered this turn (Wary Farmer itself doesn't count)" do
    current_turn.end!

    expect(surveil_choices).to be_empty
  end

  it "doesn't count a creature that entered under an opponent's control" do
    ResolvePermanent("Grizzly Bears", owner: p2)
    current_turn.end!

    expect(surveil_choices).to be_empty
  end
end
