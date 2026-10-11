# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnsettlingTwins do
  include_context "two player game"

  it "is a 2/2 Human that manifests dread when it enters" do
    twins = ResolvePermanent("Unsettling Twins", owner: p1)
    game.settle!
    expect([twins.power, twins.toughness]).to eq([2, 2])

    game.resolve_choice!(target: game.choices.last.choices.first)
    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end
end
