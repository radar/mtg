# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BeastieBeatdown do
  include_context "two player game"

  let(:card) { Card("Beastie Beatdown", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:ogre) { ResolvePermanent("Alpine Watchdog", owner: p2) }

  before do
    go_to_main_phase!
    p1.hand.add(card)
  end

  def cast!
    p1.add_mana(red: 1, green: 1)
    p1.cast(card:) { |a| a.pay_mana(red: 1, green: 1).targeting(bears, ogre) }
    game.stack.resolve!
    game.settle!
  end

  it "has your creature deal damage equal to its power to theirs, one way" do
    cast!

    expect(ogre).to be_dead
    expect(bears.damage).to eq(0)
    expect(bears.power).to eq(2)
  end

  it "only targets your creature first and an opponent's second" do
    expect(card.target_choices.first).to eq([bears])
    expect(card.target_choices.last).to eq([ogre])
  end

  it "puts two +1/+1 counters first with delirium" do
    %w[Grizzly\ Bears Island Lightning\ Bolt Cultivate].each { p1.graveyard.add(Card(_1, owner: p1)) }
    cast!

    expect(bears.power).to eq(4)
    expect(ogre).to be_dead
  end
end
