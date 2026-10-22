# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CorruptedShapeshifter do
  include_context "two player game"

  let(:keywords) { Magic::Cards::Keywords }
  let(:shifter) { ResolvePermanent("Corrupted Shapeshifter", owner: p1) }

  before { shifter }

  it "is colorless" do
    expect(shifter.colors).to be_empty
  end

  it "stays on the battlefield while the form is pending" do
    game.settle!
    expect(shifter.zone).not_to be_nil
    expect(game.battlefield.creatures).to include(shifter)
  end

  it "can become a 3/3 flier" do
    game.resolve_choice!(form: :flier)
    expect(shifter.power).to eq(3)
    expect(shifter.toughness).to eq(3)
    expect(shifter.has_keyword?(keywords::FLYING)).to be(true)
    expect(shifter.has_keyword?(keywords::VIGILANCE)).to be(false)
  end

  it "can become a 2/5 with vigilance" do
    game.resolve_choice!(form: :vigilant)
    expect(shifter.power).to eq(2)
    expect(shifter.toughness).to eq(5)
    expect(shifter.has_keyword?(keywords::VIGILANCE)).to be(true)
    expect(shifter.has_keyword?(keywords::FLYING)).to be(false)
  end

  it "can become a 0/12 with defender" do
    game.resolve_choice!(form: :wall)
    expect(shifter.power).to eq(0)
    expect(shifter.toughness).to eq(12)
    expect(shifter.has_keyword?(keywords::DEFENDER)).to be(true)
  end

  it "takes the first form when the choice is skipped" do
    game.skip_choice!
    game.settle!
    expect(shifter.power).to eq(3)
    expect(shifter.has_keyword?(keywords::FLYING)).to be(true)
    expect(game.battlefield.creatures).to include(shifter)
  end

  it "rejects an unknown form" do
    expect { game.resolve_choice!(form: :bogus) }.to raise_error(ArgumentError)
  end
end
