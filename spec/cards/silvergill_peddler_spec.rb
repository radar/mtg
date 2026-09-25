# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SilvergillPeddler do
  include_context "two player game"

  let!(:peddler) { ResolvePermanent("Silvergill Peddler", owner: p1) }

  it "is a 2/3 Merfolk Citizen" do
    expect(peddler.power).to eq(2)
    expect(peddler.toughness).to eq(3)
    expect(peddler).to be_type("Merfolk")
    expect(peddler).to be_type("Citizen")
  end

  it "draws a card, then discards a card, whenever it becomes tapped" do
    expect { peddler.tap!; game.settle! }.to change { p1.hand.count }.by(1)

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Discard)
    card = p1.hand.first
    expect { game.resolve_choice!(card:) }.to change { p1.hand.count }.by(-1)
    expect(card.zone).to be_graveyard
  end

  it "loots when it attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    expect { p1.declare_attacker(attacker: peddler, target: p2); game.settle! }.to change { p1.hand.count }.by(1)

    expect(game.choices.last).to be_a(Magic::Choice::Discard)
  end

  it "doesn't trigger when another permanent becomes tapped" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    expect { other.tap! }.not_to(change { p1.hand.count })
    expect(game.choices).to be_empty
  end
end
