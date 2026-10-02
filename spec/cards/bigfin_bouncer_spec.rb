# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BigfinBouncer do
  include_context "two player game"

  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:other_rival) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 3/2 Shark Pirate" do
    bouncer = ResolvePermanent("Bigfin Bouncer", owner: p1)

    expect([bouncer.power, bouncer.toughness]).to eq([3, 2])
  end

  it "returns target creature an opponent controls to its owner's hand" do
    ResolvePermanent("Bigfin Bouncer", owner: p1)
    game.resolve_choice!(target: rival)

    expect(rival.card.zone).to be_hand
    expect(other_rival.zone).to be_battlefield
  end

  it "can't target your own creatures" do
    ResolvePermanent("Bigfin Bouncer", owner: p1)

    expect(game.choices.last.choices).not_to include(mine)
  end
end
