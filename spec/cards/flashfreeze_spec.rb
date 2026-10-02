# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Flashfreeze do
  include_context "two player game"
  before { go_to_main_phase! }

  def cast_at_p1(card_name, player: p2, **payment)
    spell_card = Card(card_name, owner: player)
    player.add_mana(red: 1)
    player.cast(card: spell_card) { |a| a.pay_mana(red: 1).targeting(p1) }
    spell_card
  end

  def flashfreeze!(spell)
    p1.add_mana(blue: 2)
    p1.cast(card: Card("Flashfreeze", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(spell) }
    game.stack.resolve!
  end

  it "counters target red spell" do
    bolt = cast_at_p1("Lightning Bolt")
    flashfreeze!(game.stack.spells.first)

    expect(bolt.zone).to be_graveyard
    expect(p1.life).to eq(20)
  end

  it "doesn't counter a blue spell" do
    p2.add_mana(blue: 1)
    p2.cast(card: Card("Dive Down", owner: p2)) { |a| a.pay_mana(blue: 1).targeting(ResolvePermanent("Grizzly Bears", owner: p2)) }
    p1.add_mana(blue: 2)

    expect { p1.cast(card: Card("Flashfreeze", owner: p1)) { |a| a.pay_mana(generic: { blue: 1 }, blue: 1).targeting(game.stack.spells.first) } }
      .to raise_error(Magic::Actions::Cast::InvalidTarget)
  end
end
