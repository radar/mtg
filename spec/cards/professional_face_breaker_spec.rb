# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ProfessionalFaceBreaker do
  include_context "two player game"

  let!(:breaker) { ResolvePermanent("Professional Face-Breaker", owner: p1) }

  def treasures = p1.permanents.select { _1.type?("Treasure") }

  def combat_damage(source, to: p2)
    game.notify!(Magic::Events::DamageDealt.new(source: source, target: to, damage: 2, combat: true))
    game.settle!
  end

  it "is a 2/3 with menace" do
    expect([breaker.power, breaker.toughness]).to eq([2, 3])
    expect(breaker).to have_keyword(:menace)
  end

  it "creates a Treasure when a creature you control deals combat damage to a player" do
    combat_damage(breaker)

    expect(treasures.count).to eq(1)
  end

  it "creates only one Treasure when several creatures deal damage in the same step" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    combat_damage(breaker)
    combat_damage(bears)

    expect(treasures.count).to eq(1)
  end

  it "does not trigger for damage to a creature, noncombat damage or an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    game.notify!(Magic::Events::DamageDealt.new(source: breaker, target: theirs, damage: 2, combat: true))
    game.notify!(Magic::Events::DamageDealt.new(source: breaker, target: p2, damage: 2, combat: false))
    combat_damage(theirs, to: p1)

    expect(treasures).to be_empty
  end

  context "sacrificing a Treasure" do
    before { go_to_main_phase! }

    it "exiles the top card of the library, which may be played this turn" do
      combat_damage(breaker)
      treasure = treasures.first
      top = p1.library.first

      p1.activate_ability(ability: breaker.activated_abilities.first) { |a| a.pay_sacrifice(treasure) }
      game.stack.resolve!

      expect(top.zone).to be_exile
      expect(game.play_permissions.instance_variable_get(:@permissions).map(&:card)).to include(top)
      expect(treasures).to be_empty
    end
  end
end
