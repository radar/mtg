# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::NowhereToRun do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
  let!(:ogre) { ResolvePermanent("Serra Angel", owner: p2) }

  def enter_nowhere_to_run
    ResolvePermanent("Nowhere To Run", owner: p1)
    game.settle!
  end

  it "has flash" do
    expect(Card("Nowhere To Run", owner: p1)).to be_flash
  end

  it "gives target creature an opponent controls -3/-3 until end of turn" do
    enter_nowhere_to_run
    game.resolve_choice!(target: ogre)
    game.settle!

    expect(ogre.power).to eq(1)
    expect(ogre.toughness).to eq(1)
  end

  it "lets opponents' hexproof creatures be targeted" do
    giant = ResolvePermanent("Gigantic Big Bear", owner: p2)
    expect(giant.can_be_targeted_by?(Card("Lightning Bolt", owner: p1), controller: p1)).to be(false)

    enter_nowhere_to_run
    game.resolve_choice!(target: ogre)
    game.settle!

    expect(giant.can_be_targeted_by?(Card("Lightning Bolt", owner: p1), controller: p1)).to be(true)
  end

  it "stops ward from triggering on opponents' creatures" do
    terror = ResolvePermanent("Terror Of The Peaks", owner: p2)
    enter_nowhere_to_run
    game.resolve_choice!(target: ogre)
    game.settle!

    p1.add_mana(red: 1)
    action = cast_action(card: Card("Lightning Bolt", owner: p1), player: p1)
    action.pay_mana(red: 1)
    action.targeting(terror)
    game.take_action(action)
    game.settle!

    expect(game.choices).to be_empty
  end
end
