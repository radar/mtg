# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CelestialArmor do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:rival) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def cast_armor
    p1.add_mana(white: 3)
    p1.cast(card: Card("Celestial Armor", owner: p1)) { |a| a.pay_mana(generic: { white: 2 }, white: 1) }
    game.stack.resolve!
    game.settle!
  end

  it "has flash" do
    expect(Card("Celestial Armor", owner: p1).has_keyword?(:flash)).to eq(true)
  end

  it "attaches to target creature you control when it enters" do
    cast_armor
    game.resolve_choice!(target: bears)
    game.tick!

    expect(p1.permanents.by_name("Celestial Armor").first.attached_to).to eq(bears)
  end

  it "gives that creature hexproof and indestructible until end of turn" do
    cast_armor
    game.resolve_choice!(target: bears)
    game.tick!

    expect(bears).to be_hexproof
    expect(bears).to be_indestructible
    expect(other).not_to be_hexproof
  end

  it "wears the hexproof and indestructible off at end of turn but keeps the equipment bonus" do
    cast_armor
    game.resolve_choice!(target: bears)
    current_turn.end!
    current_turn.cleanup!
    resolve_cleanup_discards!
    game.tick!

    expect(bears).not_to be_hexproof
    expect(bears).not_to be_indestructible
    expect([bears.power, bears.toughness]).to eq([4, 2])
    expect(bears).to be_flying
  end

  it "can't attach to an opponent's creature" do
    cast_armor

    expect(game.choices.last.choices).not_to include(rival)
  end

  it "equips for {3}{W}" do
    cast_armor
    game.resolve_choice!(target: bears)
    armor = p1.permanents.by_name("Celestial Armor").first
    p1.add_mana(white: 4)
    p1.activate_ability(ability: armor.activated_abilities.first) { _1.pay_mana(generic: { white: 3 }, white: 1).targeting(other) }
    game.stack.resolve!
    game.tick!

    expect(armor.attached_to).to eq(other)
    expect(other).to be_flying
  end
end
