# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DualcasterMage do
  include_context "two player game"

  def put_shock_on_stack(player, target)
    player.add_mana(red: 1)
    action = cast_action(player: player, card: Card("Shock", owner: player)).pay_mana(red: 1).targeting(target)
    action.perform
    action
  end

  # The Mage's enters trigger goes on the stack above Shock: resolve just that, leaving Shock waiting beneath it.
  def enter_mage
    mage = ResolvePermanent("Dualcaster Mage", owner: p1, settle: false)
    game.state_based_actions_checkpoint!
    game.stack.resolve_top!
    mage
  end

  it "is a 2/2 with flash" do
    mage = ResolvePermanent("Dualcaster Mage", owner: p1)
    expect([mage.power, mage.toughness]).to eq([2, 2])
    expect(Card("Dualcaster Mage", owner: p1).keywords).to include(Magic::Cards::Keywords::FLASH)
  end

  it "copies a target instant or sorcery spell, the copy keeping the targets" do
    shock = put_shock_on_stack(p2, p1)
    enter_mage
    expect(game.choices.last).to be_a(described_class::CopyChoice)

    game.resolve_choice!(target: shock)
    game.skip_choice!
    game.stack.resolve!

    expect(p1.life).to eq(20 - 2 - 2)
  end

  it "offers new targets for the copy" do
    shock = put_shock_on_stack(p2, p1)
    enter_mage
    game.resolve_choice!(target: shock)

    expect(game.choices.last).to be_a(Magic::Choice::MayCopyTargets)
  end

  it "does nothing when no instant or sorcery spell is on the stack" do
    ResolvePermanent("Dualcaster Mage", owner: p1)

    expect(game.choices).to be_empty
  end

  it "can't copy a creature spell" do
    p1.add_mana(green: 2)
    bears = Card("Grizzly Bears", owner: p2)
    p2.hand.add(bears)
    p2.add_mana(green: 2)
    cast_action(player: p2, card: bears).pay_mana(generic: { green: 1 }, green: 1).perform
    enter_mage

    expect(game.choices).to be_empty
  end
end
