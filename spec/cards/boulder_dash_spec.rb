# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BoulderDash do
  include_context "two player game"

  let(:dash) { Card("Boulder Dash") }
  let!(:giant) { ResolvePermanent("Colossal Dreadmaw", owner: p2) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  before { go_to_main_phase! }

  def cast_at(*targets)
    p1.add_mana(red: 2)
    p1.cast(card: dash) do
      _1.pay_mana(generic: { red: 1 }, red: 1)
      _1.targeting(*targets)
    end
    game.stack.resolve!
    game.settle!
  end

  it "deals 2 damage to one target and 1 damage to another" do
    cast_at(giant, p2)

    expect(giant.damage).to eq(2)
    expect(p2.life).to eq(19)
  end

  it "can target a player first and a creature second" do
    cast_at(p2, bears)

    expect(p2.life).to eq(18)
    expect(bears.damage).to eq(1)
  end

  it "kills a creature dealt 2 damage" do
    cast_at(bears, p2)

    expect(game.battlefield.creatures).not_to include(bears)
    expect(p2.life).to eq(19)
  end

  it "can't target the same thing twice" do
    p1.add_mana(red: 2)
    expect do
      p1.cast(card: dash) do
        _1.pay_mana(generic: { red: 1 }, red: 1)
        _1.targeting(giant, giant)
      end
    end.to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
