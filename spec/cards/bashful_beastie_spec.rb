# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BashfulBeastie do
  include_context "two player game"

  let!(:beastie) { ResolvePermanent("Bashful Beastie", owner: p1) }

  it "is a 5/4 Beast" do
    expect([beastie.power, beastie.toughness]).to eq([5, 4])
  end

  it "manifests dread when it dies" do
    beastie.destroy!
    game.settle!
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(p1.graveyard.cards.map(&:name)).to include("Bashful Beastie")
    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end
end
