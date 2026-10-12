# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TheMindskinner do
  include_context "two player game"

  let!(:mindskinner) { ResolvePermanent("The Mindskinner", owner: p1) }

  def shock(player, target)
    spell = Card("Shock", owner: player)
    player.hand.add(spell)
    player.add_mana(red: 1)
    player.cast(card: spell) { |a| a.pay_mana(red: 1).targeting(target) }
    game.settle!
  end

  it "is a legendary 10/1 enchantment creature that can't be blocked" do
    expect([mindskinner.power, mindskinner.toughness]).to eq([10, 1])
    expect(mindskinner.card).to be_legendary
    expect(mindskinner.card).to be_enchantment
    expect(mindskinner.can_be_blocked?(ResolvePermanent("Grizzly Bears", owner: p2))).to be(false)
  end

  it "turns combat damage to an opponent into milling" do
    5.times { p2.library.add(Card("Forest", owner: p2)) }
    library_before = p2.library.count
    skip_to_combat!
    current_turn.declare_attackers!
    current_turn.declare_attacker(mindskinner, target: p2)
    current_turn.attackers_declared!
    go_to_combat_damage!
    game.settle!

    expect(p2.life).to eq(20)
    expect(p2.library.count).to eq(library_before - 10)
    expect(p2.graveyard.count).to eq(10)
  end

  it "turns noncombat damage from your sources into milling" do
    shock(p1, p2)

    expect(p2.life).to eq(20)
    expect(p2.graveyard.cards.count).to eq(2)
  end

  it "doesn't change damage to creatures or to you" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    shock(p1, bears)
    expect(p2.graveyard.cards.map(&:name)).to eq(["Grizzly Bears"])

    shock(p2, p1)
    expect(p1.life).to eq(18)
  end

  it "doesn't change damage an opponent's source deals to its own player" do
    shock(p2, p2)

    expect(p2.life).to eq(18)
  end
end
