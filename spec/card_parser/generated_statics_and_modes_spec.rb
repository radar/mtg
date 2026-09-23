# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated statics, counters, grants and modes in play" do
  include CardParserHelpers
  include_context "two player game"

  it "buffs and grants a keyword to your other creatures only" do
    load_card("Parsed Marshal {2}{W}\nCreature — Human Knight\nOther creatures you control get +1/+1 and have vigilance.\n2/2\n")
    marshal = ResolvePermanent("Parsed Marshal", owner: p1)
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    game.tick!

    expect([bears.power, bears.toughness, bears.vigilant?]).to eq([3, 3, true])
    expect([marshal.power, marshal.vigilant?]).to eq([2, false])
    expect([theirs.power, theirs.vigilant?]).to eq([2, false])
  end

  it "enters with +1/+1 counters, so a 0/0 survives" do
    load_card("Parsed Ooze {1}{G}\nCreature — Ooze\nParsed Ooze enters with two +1/+1 counters on it.\n0/0\n")
    go_to_main_phase!
    ooze = Card("Parsed Ooze", owner: p1)
    p1.hand.add(ooze)
    p1.add_mana(green: 2)
    p1.cast(card: ooze) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!
    game.tick!

    permanent = p1.creatures.by_name("Parsed Ooze").first
    expect([permanent.power, permanent.toughness]).to eq([2, 2])
  end

  it "grants a keyword and a pump until end of turn" do
    load_card("Parsed Rager {1}{R}\nCreature — Goblin\n{R}: Parsed Rager gets +1/+0 and gains first strike until end of turn.\n2/1\n")
    rager = ResolvePermanent("Parsed Rager", owner: p1)
    p1.add_mana(red: 1)
    p1.activate_ability(ability: rager.activated_abilities.first) { _1.pay_mana(red: 1) }
    game.stack.resolve!
    game.tick!
    expect([rager.power, rager.first_strike?]).to eq([3, true])

    rager.cleanup!
    game.tick!
    expect([rager.power, rager.first_strike?]).to eq([2, false])
  end

  it "returns a creature card from your graveyard when a generated creature enters" do
    load_card("Parsed Digger {3}{B}\nCreature — Zombie\nWhen Parsed Digger enters, you may return target creature card from your graveyard to your hand.\n2/2\n")
    bears = Card("Grizzly Bears", owner: p1)
    p1.graveyard.add(bears)
    p1.graveyard.add(Card("Forest", owner: p1))
    ResolvePermanent("Parsed Digger", owner: p1)

    game.resolve_choice!
    expect(bears.zone).to be_hand
  end

  context "with a modal spell" do
    let(:spell_class) do
      load_card("Parsed Charm {1}{R}\nInstant\nChoose one —\n• Parsed Charm deals 3 damage to target creature.\n" \
                "• Destroy target artifact.\n• You gain 3 life.\n")
    end
    let(:charm) { Card("Parsed Charm", owner: p1) }

    def cast_mode(index, target = nil)
      p1.hand.add(charm)
      p1.add_mana(red: 2)
      p1.cast(card: charm) do |action|
        action.choose_mode(charm.modes[index]) { |mode| mode.targeting(target) if target }
        action.pay_mana(generic: { red: 1 }, red: 1)
      end
      game.stack.resolve!
    end

    before { spell_class }

    it "deals damage in the first mode" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      cast_mode(0, bears)
      expect(bears.card.zone).to be_graveyard
    end

    it "destroys an artifact in the second mode" do
      stone = ResolvePermanent("Mind Stone", owner: p2)
      cast_mode(1, stone)
      expect(stone.card.zone).to be_graveyard
    end

    it "gains life in the third mode" do
      cast_mode(2)
      expect(p1.life).to eq(23)
    end
  end
end
