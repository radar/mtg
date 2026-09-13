# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PlayWithFire do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }

  let(:play_with_fire) { Card("Play With Fire") }

  it "deals 2 damage to a creature" do
    p1.add_mana(red: 1)
    action = cast_action(player: p1, card: play_with_fire)
    action.pay_mana(red: 1)
    action.targeting(wood_elves)
    game.take_action(action)
    game.stack.resolve!

    expect(wood_elves.damage).to eq(2)
  end

  it "does not scry when a creature is dealt damage" do
    p1.add_mana(red: 1)
    action = cast_action(player: p1, card: play_with_fire)
    action.pay_mana(red: 1)
    action.targeting(wood_elves)
    game.take_action(action)
    game.stack.resolve!

    expect(game.choices).to be_empty
  end

  it "deals 2 damage to a player" do
    p2_starting_life = p2.life
    p1.add_mana(red: 1)
    action = cast_action(player: p1, card: play_with_fire)
    action.pay_mana(red: 1)
    action.targeting(p2)
    game.take_action(action)
    game.stack.resolve!

    expect(p2.life).to eq(p2_starting_life - 2)
  end

  it "scries 1 when a player is dealt damage" do
    top_card = p1.library.first
    p1.add_mana(red: 1)
    action = cast_action(player: p1, card: play_with_fire)
    action.pay_mana(red: 1)
    action.targeting(p2)
    game.take_action(action)
    game.stack.resolve!

    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Scry)

    game.resolve_choice!(bottom: [top_card])

    expect(p1.library.last).to eq(top_card)
  end
end
