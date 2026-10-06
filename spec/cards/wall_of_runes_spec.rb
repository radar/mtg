# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::WallOfRunes do
  include_context "two player game"

  let!(:wall) { ResolvePermanent("Wall Of Runes", owner: p1) }

  it "is a 0/4 Wall with defender" do
    expect([wall.power, wall.toughness]).to eq([0, 4])
    expect(wall.can_attack?).to eq(false)
  end

  it "scries 1 when it enters" do
    expect(game.choices.last).to be_a(Magic::Choice::Scry)
  end

  it "may put the top card on the bottom" do
    top = p1.library.first
    game.resolve_choice!(top: [], bottom: [top])

    expect(p1.library.last).to eq(top)
  end
end
