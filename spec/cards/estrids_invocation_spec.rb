# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EstridsInvocation do
  include_context "two player game"

  let(:invocation) { Card("Estrid's Invocation", owner: p1) }

  before { go_to_main_phase! }

  def cast_invocation
    p1.hand.add(invocation)
    p1.add_mana(blue: 3)
    p1.cast(card: invocation) { |a| a.pay_mana(generic: { blue: 2 }, blue: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "enters as a copy of an enchantment you control" do
    ResolvePermanent("Monstrous Vortex", owner: p1)
    cast_invocation
    game.resolve_choice!
    game.resolve_choice!(target: p1.enchantments.first)

    copy = p1.enchantments.find { _1.card == invocation }
    expect(copy.name).to eq("Monstrous Vortex")
  end

  it "stays as itself when the copy is declined" do
    ResolvePermanent("Monstrous Vortex", owner: p1)
    cast_invocation
    game.skip_choice!

    expect(p1.enchantments.map(&:name)).to include("Estrid's Invocation")
  end

  it "enters as itself with no other enchantment to copy" do
    cast_invocation

    expect(game.choices).to be_empty
    expect(p1.enchantments.map(&:name)).to eq(["Estrid's Invocation"])
  end

  it "gives the copy a blink ability at the beginning of your upkeep" do
    ResolvePermanent("Monstrous Vortex", owner: p1)
    cast_invocation
    game.resolve_choice!
    game.resolve_choice!(target: p1.enchantments.first)
    game.settle!
    2.times { game.next_turn }
    go_to_main_phase!
    game.settle!

    expect(game.choices.first).to be_a(Magic::Cards::EstridsInvocation::BlinkChoice)
    game.resolve_choice!
    game.settle!

    expect(p1.enchantments.map(&:name)).to include("Estrid's Invocation")
  end

  it "has no blink ability when it did not copy anything" do
    cast_invocation
    2.times { game.next_turn }
    go_to_main_phase!
    game.settle!

    expect(game.choices).to be_empty
  end
end
