# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KaervekTheMerciless do
  include_context "two player game"

  let!(:kaervek) { ResolvePermanent("Kaervek The Merciless", owner: p1) }

  before { go_to_main_phase_for!(p2) }

  def cast_bears!(owner)
    spell = Card("Grizzly Bears", owner: owner).tap { owner.hand.add(_1) } # mana value 2
    owner.add_mana(green: 2)
    owner.cast(card: spell) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.settle!
  end

  it "deals damage equal to the spell's mana value to any target" do
    cast_bears!(p2)
    game.resolve_choice!(target: p2)
    game.settle!

    expect(p2.life).to eq(18)
  end

  it "can hit a creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_bears!(p2)
    game.resolve_choice!(target: bears)
    game.settle!

    expect(bears.zone).to be_nil
  end

  it "ignores its controller's spells" do
    spell = Card("Lightning Bolt", owner: p1).tap { p1.hand.add(_1) }
    p1.add_mana(red: 1)
    p1.cast(card: spell) { _1.pay_mana(red: 1).targeting(p2) }
    game.settle!

    expect(game.choices.to_a.grep(described_class::DamageChoice)).to be_empty
  end
end
