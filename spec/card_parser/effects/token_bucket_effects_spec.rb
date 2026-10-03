# frozen_string_literal: true

require "spec_helper"
require_relative "../card_parser_helpers"

RSpec.describe "CardParser effects from the FDN token bucket (sacrifice choice, reveal until, mill for tokens, reflexive tap)" do
  include CardParserHelpers
  include_context "two player game"

  def tokens(player, name) = player.permanents.by_name(name).to_a

  def cast_spell(name, cost, **pay)
    go_to_main_phase!
    card = Card(name, owner: p1)
    p1.hand.add(card)
    p1.add_mana(**cost)
    p1.cast(card:) { |a| a.pay_mana(**pay) }
    game.stack.resolve!
    game.settle!
  end

  describe "may sacrifice another creature, if you do" do
    before do
      load_card("Parsed Hunter {1}\nCreature — Vampire\nWhenever ~ attacks, you may sacrifice another creature. If you do, put a +1/+1 counter on ~.\n" \
                "Whenever another nontoken creature dies, draw a card.\n2/2\n")
    end

    let!(:hunter) { ResolvePermanent("Parsed Hunter", owner: p1) }

    def attack
      skip_to_combat!
      current_turn.declare_attackers!
      current_turn.declare_attacker(hunter, target: p2)
      current_turn.attackers_declared!
      game.settle!
    end

    it "sacrifices a creature and gets a counter when accepted" do
      fodder = ResolvePermanent("Aegis Turtle", owner: p1)
      attack
      game.resolve_choice!(sacrifice: fodder)

      expect(fodder.zone).not_to be_a(Magic::Zones::Battlefield)
      expect(hunter.power).to eq(3)
    end

    it "does nothing when declined" do
      fodder = ResolvePermanent("Aegis Turtle", owner: p1)
      attack
      game.skip_choice!

      expect(p1.creatures).to include(fodder)
      expect(hunter.power).to eq(2)
    end

    it "offers no choice with nothing else to sacrifice" do
      attack
      expect(game.choices).to be_empty
      expect(hunter.power).to eq(2)
    end

    it "draws when another nontoken creature (any controller) dies" do
      victim = ResolvePermanent("Aegis Turtle", owner: p2)
      expect { victim.destroy!; game.settle! }.to change { p1.hand.count }.by(1)
    end
  end

  it "draws on a nontoken creature of yours dying, but not a token, and loses life" do
    load_card("Parsed Reaper {1}\nCreature — Zombie\nWhenever a nontoken creature you control dies, ~ deals 1 damage to you and you draw a card.\n3/2\n")
    ResolvePermanent("Parsed Reaper", owner: p1)
    victim = ResolvePermanent("Aegis Turtle", owner: p1)
    expect { victim.destroy!; game.settle! }.to change { p1.hand.count }.by(1).and change { p1.life }.by(-1)

    copy = Magic::Permanent.resolve(game:, owner: p1, card: victim.copiable_card, token: true, copy: true, cast: false)
    expect { copy.destroy!; game.settle! }.not_to(change { p1.hand.count })
    expect(p1.life).to eq(19)
  end

  it "reveals until a creature, takes it, and puts the rest on the bottom" do
    load_card("Parsed Spinner {1}\nCreature — Spider\nWhenever another nontoken creature you control dies, you may reveal cards from the top of your library until you reveal a creature card. Put that card into your hand and the rest on the bottom of your library in a random order.\n2/2\n")
    ResolvePermanent("Parsed Spinner", owner: p1)
    victim = ResolvePermanent("Aegis Turtle", owner: p1)
    p1.library.items.clear
    lands = 2.times.map { Card("Island", owner: p1) }
    creature = Card("Aegis Turtle", owner: p1)
    other = Card("Island", owner: p1)
    [*lands, creature, other].reverse_each { p1.library.add(_1) }

    victim.destroy!
    game.settle!
    game.resolve_choice!

    expect(p1.hand.cards).to include(creature)
    expect(p1.library.items.first).to eq(other)
    expect(p1.library.items.last(2)).to match_array(lands)
    expect(p1.library.count).to eq(3)
  end

  it "mills each player X cards and makes a tapped Zombie per creature card milled" do
    load_card("Parsed Summons {X}{B}\nSorcery\nEach player mills X cards. For each creature card put into a graveyard this way, you create a tapped 2/2 black Zombie creature token.\n")
    go_to_main_phase!
    [p1, p2].each do |player|
      player.library.items.clear
      2.times { player.library.add(Card("Aegis Turtle", owner: player)) }
      player.library.add(Card("Island", owner: player))
    end
    card = Card("Parsed Summons", owner: p1)
    p1.hand.add(card)
    p1.add_mana(black: 3)
    p1.cast(card:, value_for_x: 2) { |a| a.pay_mana(x: { black: 2 }, black: 1) }
    game.stack.resolve!
    game.settle!

    zombies = tokens(p1, "Zombie")
    expect(zombies.size).to eq(2)
    expect(zombies).to all(be_tapped)
    expect(p1.graveyard.count).to eq(3) # the two milled cards and the spell
    expect(tokens(p2, "Zombie")).to be_empty
  end

  it "makes tokens then taps an opponent's creature, even with nothing to tap" do
    load_card("Parsed Trick {1}\nInstant\nCreate two 1/1 blue Faerie creature tokens with flying. When you do, tap target creature an opponent controls.\n")
    cast_spell("Parsed Trick", { generic: 1 }, generic: { generic: 1 })
    expect(tokens(p1, "Faerie").size).to eq(2)
    expect(game.choices).to be_empty

    target = ResolvePermanent("Aegis Turtle", owner: p2)
    ResolvePermanent("Aegis Turtle", owner: p2)
    card = Card("Parsed Trick", owner: p1)
    p1.hand.add(card)
    p1.add_mana(generic: 1)
    p1.cast(card:) { |a| a.pay_mana(generic: { generic: 1 }) }
    game.stack.resolve!
    game.resolve_choice!(target:)
    expect(target).to be_tapped
  end

  it "counts the life you gained this turn" do
    load_card("Parsed Snack {1}\nEnchantment\n{B}, Sacrifice ~: Target opponent loses X life, where X is the amount of life you gained this turn.\n")
    go_to_main_phase!
    snack = ResolvePermanent("Parsed Snack", owner: p1)
    p1.gain_life(3)
    p1.gain_life(2)
    p1.add_mana(black: 1)
    p1.activate_ability(ability: snack.activated_abilities.first) { _1.pay_mana(black: 1).targeting(p2) }
    game.stack.resolve!
    expect(p2.life).to eq(15)
  end

  it "fires on the first life gain each of your turns only" do
    load_card("Parsed Collector {1}\nCreature — Human\nWhenever you gain life for the first time during each of your turns, create a 1/1 white Cat creature token.\n2/2\n")
    ResolvePermanent("Parsed Collector", owner: p1)
    p1.gain_life(1)
    game.settle!
    p1.gain_life(1)
    game.settle!
    expect(tokens(p1, "Cat").size).to eq(1)

    game.next_turn
    p1.gain_life(1)
    game.settle!
    expect(tokens(p1, "Cat").size).to eq(1)
  end

  it "returns a dying nontoken, non-Angel creature with a counter, flying and the Angel type" do
    load_card("Parsed Call {1}\nEnchantment\nWhenever a nontoken, non-Angel creature you control dies, return that card to the battlefield under its owner's control with a +1/+1 counter on it. It has flying and is an Angel in addition to its other types.\n")
    ResolvePermanent("Parsed Call", owner: p1)
    ResolvePermanent("Aegis Turtle", owner: p1).destroy!
    game.settle!

    back = p1.creatures.find { _1.name == "Aegis Turtle" }
    expect(back.counters.count).to eq(1)
    expect(back).to be_flying
    expect(back.type?("Angel")).to eq(true)
  end

  it "makes a token per point of excess damage to a creature" do
    load_card("Parsed Negotiation {X}{R}\nSorcery\n~ deals X damage to target creature. Create a number of 1/1 red Goblin creature tokens equal to the amount of excess damage dealt to that creature this way.\n")
    bears = ResolvePermanent("Aegis Turtle", owner: p2) # 0/5
    go_to_main_phase!
    card = Card("Parsed Negotiation", owner: p1)
    p1.hand.add(card)
    p1.add_mana(red: 8)
    p1.cast(card:, value_for_x: 7) { |a| a.pay_mana(x: { red: 7 }, red: 1).targeting(bears) }
    game.stack.resolve!
    game.settle!

    expect(tokens(p1, "Goblin").size).to eq(2)
  end

  it "reads a ward cost of mana and life, and tokens with haste sized by the spell's mana value" do
    code = generate("Parsed Goliath {5}\nCreature — Nightmare\nFlying\nWard—{3}, Pay 3 life.\n" \
                    "Whenever you cast a noncreature spell, create X 1/1 red Goblin creature tokens, where X is the mana value of that spell. They gain haste until end of turn.\n6/6\n")

    expect(code).to include("ward generic: 3, life: 3")
    expect(code).to include("amount: event.spell.mana_value")
    expect(code).to include("keyword: :haste")
  end

  it "reads nontoken Cat enters triggers for ~ or another" do
    load_card("Parsed Leader {1}\nCreature — Cat\nWhenever ~ or another nontoken Cat you control enters, create a 1/1 white Cat creature token.\n2/2\n")
    ResolvePermanent("Parsed Leader", owner: p1)
    expect(tokens(p1, "Cat").size).to eq(1)
    ResolvePermanent("Parsed Leader", owner: p1)
    expect(tokens(p1, "Cat").size).to eq(3)
    p1.permanents.by_name("Cat").first.then { |t| Magic::Permanent.resolve(game:, owner: p1, card: t.copiable_card, token: true, copy: true, cast: false) }
    game.settle!
    expect(tokens(p1, "Cat").size).to eq(4)
  end
end
