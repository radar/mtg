# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EreborFlamesmith do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:flamesmith) { ResolvePermanent("Erebor Flamesmith", owner: p1) }
  let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_unsummon(player, target = bear)
    spell = Card("Unsummon", owner: player)
    player.hand.add(spell)
    player.add_mana(blue: 1)
    player.cast(card: spell) { |a| a.pay_mana(blue: 1).targeting(target) }
  end

  it "is a 2/1 Dwarf Artificer" do
    expect([flamesmith.power, flamesmith.toughness]).to eq([2, 1])
    expect(flamesmith.type?("Dwarf")).to eq(true)
    expect(flamesmith.type?("Artificer")).to eq(true)
  end

  it "deals 1 damage to each opponent when you cast an instant" do
    cast_unsummon(p1)
    game.stack.resolve!
    game.settle!

    expect(p2.life).to eq(19)
    expect(p1.life).to eq(20)
  end

  it "deals 1 damage when you cast a sorcery" do
    spell = Card("Mordor Muster", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(black: 2)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { black: 1 }, black: 1) }
    game.stack.resolve!
    game.settle!

    expect(p2.life).to eq(19)
  end

  it "triggers for each instant or sorcery you cast" do
    cast_unsummon(p1)
    game.stack.resolve!
    game.settle!
    cast_unsummon(p1, flamesmith)
    game.stack.resolve!
    game.settle!

    expect(p2.life).to eq(18)
  end

  it "does not trigger for a creature spell" do
    spell = Card("Grizzly Bears", owner: p1)
    p1.hand.add(spell)
    p1.add_mana(green: 2)
    p1.cast(card: spell) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
    game.settle!

    expect(p2.life).to eq(20)
    expect(game.choices).to be_empty
  end

  it "does not trigger when an opponent casts an instant" do
    cast_unsummon(p2)
    game.stack.resolve!
    game.settle!

    expect(p2.life).to eq(20)
    expect(p1.life).to eq(20)
    expect(game.choices).to be_empty
  end
end
