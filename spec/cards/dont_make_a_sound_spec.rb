# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DontMakeASound do
  include_context "two player game"
  before { go_to_main_phase_for!(p2) }

  subject(:dont_make_a_sound) { Card("Don't Make A Sound") }

  let(:sol_ring) { Card("Sol Ring", owner: p2) }

  before do
    p2.add_mana(blue: 1)
    sol_ring_cast = p2.cast(card: sol_ring) { _1.pay_mana(generic: { blue: 1 }) }

    p1.add_mana(blue: 2)
    p1.cast(card: dont_make_a_sound) do
      _1.pay_mana(generic: { blue: 1 }, blue: 1)
      _1.targeting(sol_ring_cast)
    end
    game.stack.resolve!
  end

  it "counters the spell if its controller doesn't pay {2}" do
    game.resolve_choice!
    game.stack.resolve!

    expect(sol_ring.zone).to be_graveyard
  end

  it "doesn't counter the spell and surveils 2 if its controller pays {2}" do
    choice = game.choices.first
    p2.add_mana(white: 2)
    choice.pay(p2, generic: { white: 2 })
    game.resolve_choice!

    expect(game.choices.first).to be_a(Magic::Choice::Surveil)
    expect(game.choices.first.amount).to eq(2)
    game.skip_choice!
    game.stack.resolve!
    expect(sol_ring.zone).to be_battlefield
  end
end
