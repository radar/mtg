# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ChandrasPyrohelix do
  include_context "two player game"

  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p2) }
  let!(:grizzly_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  let(:chandras_pyrohelix) { Card("Chandra's Pyrohelix") }

  it "deals all 2 damage to a single target" do
    p1.add_mana(red: 2)
    action = cast_action(player: p1, card: chandras_pyrohelix)
    action.pay_mana(generic: { red: 1 }, red: 1)
    game.take_action(action)
    game.stack.resolve!

    game.resolve_choice!(distribution: { wood_elves => 2 })

    expect(wood_elves.damage).to eq(2)
  end

  it "divides 2 damage among two targets" do
    p1.add_mana(red: 2)
    action = cast_action(player: p1, card: chandras_pyrohelix)
    action.pay_mana(generic: { red: 1 }, red: 1)
    game.take_action(action)
    game.stack.resolve!

    game.resolve_choice!(distribution: { wood_elves => 1, grizzly_bears => 1 })

    expect(wood_elves.damage).to eq(1)
    expect(grizzly_bears.damage).to eq(1)
  end

  it "can divide damage to deal 2 to a player" do
    p2_starting_life = p2.life
    p1.add_mana(red: 2)
    action = cast_action(player: p1, card: chandras_pyrohelix)
    action.pay_mana(generic: { red: 1 }, red: 1)
    game.take_action(action)
    game.stack.resolve!

    game.resolve_choice!(distribution: { p2 => 2 })

    expect(p2.life).to eq(p2_starting_life - 2)
  end
end
