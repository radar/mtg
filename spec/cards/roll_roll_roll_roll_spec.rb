# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::RollRollRollRoll do
  include_context "two player game"

  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:forest) { ResolvePermanent("Forest", owner: p1) }
  let!(:enemy) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let(:saga) { Card("Roll Roll Roll Roll", owner: p1) }

  before do
    p1.hand.add(saga)
    go_to_main_phase!
    p1.add_mana(blue: 3)
    p1.cast(card: saga) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
    game.tick!
    game.settle!
  end

  it "offers only your creatures and lands" do
    expect(game.choices.last.choices).to contain_exactly(bear, forest)
  end

  it "exiles the chosen creature, then returns it at the beginning of the next end step" do
    game.resolve_choice!(target: bear)

    expect(bear.card.zone).to be_exile
    expect(p1.creatures.map(&:name)).not_to include("Grizzly Bears")

    current_turn.end!
    game.settle!

    expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    expect(bear.card.zone).not_to be_exile
  end

  it "works on a land" do
    game.resolve_choice!(target: forest)

    expect(p1.lands.count).to eq(0)

    current_turn.end!
    game.settle!

    expect(p1.lands.count).to eq(1)
  end

  it "can be declined" do
    game.skip_choice!

    expect(p1.creatures).to include(bear)
  end

  it "triggers again on later chapters" do
    game.skip_choice!
    2.times { game.next_turn }
    go_to_main_phase!
    game.stack.resolve!
    game.tick!
    game.settle!
    game.resolve_choice!(target: bear)

    expect(bear.card.zone).to be_exile
  end
end
