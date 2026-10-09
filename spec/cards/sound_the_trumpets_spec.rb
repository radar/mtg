# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SoundTheTrumpets do
  include_context "two player game"
  before { go_to_main_phase_for!(p2) }

  let(:trumpets) { Card("Sound The Trumpets", owner: p1) }

  def counter_spell(spell, pay)
    p2.hand.add(spell)
    p1.hand.add(trumpets)
    p2.add_mana(red: 1, green: 4)
    action = p2.cast(card: spell) { _1.pay_mana(**pay) }
    p1.add_mana(blue: 3)
    p1.cast(card: trumpets) { _1.pay_mana(blue: 2, generic: { blue: 1 }).targeting(action) }
    game.stack.resolve!
    game.settle!
  end

  it "counters the target spell and recruits when its mana value is 2 or less" do
    sol_ring = Card("Sol Ring", owner: p2)
    counter_spell(sol_ring, generic: { red: 1 })
    discard = Card("Grizzly Bears", owner: p1)
    p1.hand.add(discard)
    game.resolve_choice!(card: discard)

    expect(sol_ring.zone).to be_graveyard
    expect(p1.creatures.map(&:name)).to include("Human Soldier")
  end

  it "doesn't recruit for a more expensive spell" do
    bear = Card("Ordinary Bear", owner: p2)
    counter_spell(bear, generic: { green: 3 }, green: 1)

    expect(bear.zone).to be_graveyard
    expect(game.choices).to be_empty
    expect(p1.creatures).to be_empty
  end
end
