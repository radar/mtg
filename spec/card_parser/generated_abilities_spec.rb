# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated activated abilities in play" do
  include CardParserHelpers
  include_context "two player game"

  def ability_of(permanent, klass = "ActivatedAbility")
    permanent.activated_abilities.find { _1.class.name.end_with?("::#{klass}") }
  end

  it "taps to deal damage to a target" do
    load_card("Parsed Pyro {2}{R}\nCreature — Human Wizard\n{T}: Parsed Pyro deals 1 damage to any target.\n1/1\n")
    pyro = ResolvePermanent("Parsed Pyro", owner: p1)
    p1.activate_ability(ability: ability_of(pyro)) { _1.targeting(p2) }
    game.stack.resolve!

    expect(p2.life).to eq(19)
    expect(pyro).to be_tapped
  end

  it "pays mana, taps and sacrifices itself to draw" do
    load_card("Parsed Stone {2}\nArtifact\n{T}: Add {C}.\n{1}, {T}, Sacrifice Parsed Stone: Draw a card.\n")
    stone = ResolvePermanent("Parsed Stone", owner: p1)
    expect(stone.activated_abilities.size).to eq(2)

    p1.add_mana(green: 1)
    p1.activate_ability(ability: ability_of(stone)) { _1.pay_mana(generic: { green: 1 }) }
    expect { game.stack.resolve! }.to change { p1.hand.count }.by(1)
    expect(stone.card.zone).to be_graveyard
  end

  it "sacrifices a creature to make the target opponent lose life" do
    load_card("Parsed Bell {3}\nArtifact\n{2}, Sacrifice a creature: Target opponent loses 2 life.\n")
    bell = ResolvePermanent("Parsed Bell", owner: p1)
    elves = ResolvePermanent("Wood Elves", owner: p1)

    p1.add_mana(black: 2)
    p1.activate_ability(ability: ability_of(bell)) do
      _1.pay_mana(generic: { black: 2 })
      _1.pay_sacrifice(elves)
      _1.targeting(p2)
    end
    game.stack.resolve!

    expect(p2.life).to eq(18)
    expect(elves.card.zone).to be_graveyard
  end

  it "pumps itself" do
    load_card("Parsed Brute {1}{R}\nCreature — Ogre\n{R}: Parsed Brute gets +1/+0 until end of turn.\n2/2\n")
    brute = ResolvePermanent("Parsed Brute", owner: p1)
    p1.add_mana(red: 2)
    2.times do
      p1.activate_ability(ability: ability_of(brute)) { _1.pay_mana(red: 1) }
      game.stack.resolve!
    end
    game.tick!
    expect([brute.power, brute.toughness]).to eq([4, 2])
  end

  it "asks before an optional effect" do
    load_card("Parsed Pry Bar {2}\nArtifact\n{T}: You may draw a card. If you do, you lose 1 life.\n")
    bar = ResolvePermanent("Parsed Pry Bar", owner: p1)
    p1.activate_ability(ability: ability_of(bar))
    game.stack.resolve!

    expect { game.resolve_choice! }.to change { p1.hand.count }.by(1)
    expect(p1.life).to eq(19)
  end

  context "with a sorcery-speed ability that scries then draws" do
    let!(:font) do
      load_card("Parsed Font {1}{U}\nEnchantment\n{2}{U}: Scry 1, then draw a card. Activate only as a sorcery.\n")
      ResolvePermanent("Parsed Font", owner: p1)
    end

    def activate
      p1.add_mana(blue: 3)
      p1.activate_ability(ability: ability_of(font)) { _1.pay_mana(generic: { blue: 2 }, blue: 1) }
    end

    it "can't be activated outside the main phase" do
      expect { activate }.to raise_error(Magic::IllegalAction)
    end

    it "scries, then draws once the scry is chosen" do
      go_to_main_phase!
      activate
      game.stack.resolve!
      top = p1.library.first
      expect { game.resolve_choice!(bottom: [top]) }.to change { p1.hand.count }.by(1)
      expect(p1.library.last).to eq(top)
    end
  end
end
