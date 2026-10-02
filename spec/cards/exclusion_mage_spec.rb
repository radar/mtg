# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ExclusionMage do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other_rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 2/2 Human Wizard" do
    mage = ResolvePermanent("Exclusion Mage", owner: p1)

    expect([mage.power, mage.toughness]).to eq([2, 2])
  end

  it "returns target creature an opponent controls to its owner's hand when it enters" do
    ResolvePermanent("Exclusion Mage", owner: p1)
    game.resolve_choice!(target: rival)

    expect(rival.card.zone).to be_hand
    expect(other_rival.zone).to be_battlefield
  end

  it "can't target your own creatures" do
    ResolvePermanent("Exclusion Mage", owner: p1)

    expect(game.choices.last.choices).not_to include(mine)
  end
end
