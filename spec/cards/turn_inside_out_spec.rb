# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TurnInsideOut do
  include_context "two player game"

  let(:spell) { Card("Turn Inside Out", owner: p1).tap { p1.hand.add(_1) } }
  let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  def cast_on(target)
    p1.add_mana(red: 1)
    p1.cast(card: spell) { _1.pay_mana(red: 1).targeting(target) }
    game.stack.resolve!
    game.settle!
  end

  it "gives target creature +3/+0 until end of turn" do
    cast_on(mine)
    expect([mine.power, mine.toughness]).to eq([5, 2])

    mine.cleanup!
    expect(mine.power).to eq(2)
  end

  it "manifests dread for you when your creature dies this turn" do
    cast_on(mine)
    mine.destroy!
    game.settle!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::ManifestDread)
    expect(choice.player).to eq(p1)
    game.resolve_choice!(target: choice.choices.first)
    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end

  it "manifests dread for you, not the creature's controller, when an opponent's creature dies" do
    cast_on(theirs)
    theirs.destroy!
    game.settle!

    expect(game.choices.last.player).to eq(p1)
  end

  it "does nothing if the creature doesn't die" do
    cast_on(mine)

    expect(game.choices).to be_empty
  end

  it "does nothing if the creature dies on a later turn" do
    cast_on(mine)
    mine.cleanup!
    mine.destroy!
    game.settle!

    expect(game.choices).to be_empty
  end
end
