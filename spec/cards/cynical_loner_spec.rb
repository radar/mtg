# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CynicalLoner do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:loner) { ResolvePermanent("Cynical Loner", owner: p1) }

  def to_second_main!
    current_turn.beginning_of_combat!
    current_turn.declare_attackers!
    current_turn.end_of_combat!
    current_turn.second_main!
    game.settle!
  end

  it "is a 3/1 Human Survivor" do
    expect([loner.power, loner.toughness]).to eq([3, 1])
    expect(loner.type?("Survivor")).to be(true)
  end

  it "can't be blocked by Glimmers but can be blocked by other creatures" do
    glimmer = ResolvePermanent("Lionheart Glimmer", owner: p2)
    bears = ResolvePermanent("Grizzly Bears", owner: p2)

    expect(loner.can_be_blocked?(glimmer)).to be(false)
    expect(loner.can_be_blocked?(bears)).to be(true)
  end

  it "searches for a card and puts it into the graveyard when tapped" do
    target = Card("Grizzly Bears", owner: p1)
    p1.library.add(target)
    loner.tap!

    to_second_main!
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::SearchLibrary)
    game.resolve_choice!(targets: [target])

    expect(target.zone).to be_graveyard
  end

  it "does nothing if untapped" do
    to_second_main!

    expect(game.choices).to be_empty
  end
end
