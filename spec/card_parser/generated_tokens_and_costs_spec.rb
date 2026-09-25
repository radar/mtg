# frozen_string_literal: true

require "spec_helper"
require_relative "card_parser_helpers"

RSpec.describe "CardParser generated Treasure/Food/Clue, sacrifice, life gain, draw and cost reduction in play" do
  include CardParserHelpers
  include_context "two player game"

  let!(:crew) do
    load_card("Parsed Crew {2}{R}\nCreature — Human Pirate\nWhen Parsed Crew enters, create a Treasure token.\n" \
              "Whenever you sacrifice a Treasure, Parsed Crew deals 1 damage to each opponent.\n" \
              "Whenever you gain life, put a +1/+1 counter on Parsed Crew.\n2/2\n")
    ResolvePermanent("Parsed Crew", owner: p1)
  end

  def token(name) = p1.permanents.by_name(name).first

  it "creates a Treasure that sacrifices itself for mana, firing the sacrifice trigger" do
    treasure = token("Treasure")
    expect(treasure.type?("Artifact")).to eq(true)

    p1.activate_ability(ability: treasure.activated_abilities.first) { _1.choose(:blue) }
    game.settle!
    expect(p1.mana_pool[:blue]).to eq(1)
    expect(treasure.zone).to be_nil
    expect(p1.permanents.by_name("Treasure")).to be_empty
    expect(p2.life).to eq(19)
  end

  it "gets a counter whenever you gain life, e.g. from a Food" do
    load_card("Parsed Cook {1}{G}\nSorcery\nCreate a Food token.\n")
    go_to_main_phase!
    cook = Card("Parsed Cook", owner: p1)
    p1.hand.add(cook)
    p1.add_mana(green: 2)
    p1.cast(card: cook) { _1.pay_mana(generic: { green: 1 }, green: 1) }
    game.stack.resolve!

    food = token("Food")
    p1.add_mana(green: 2)
    p1.activate_ability(ability: food.activated_abilities.first) { _1.pay_mana(generic: { green: 2 }) }
    game.stack.resolve!
    game.tick!

    expect(p1.life).to eq(23)
    expect(crew.power).to eq(3)
  end

  it "draws a card from a Clue, firing a draw trigger" do
    load_card("Parsed Sleuth {1}{U}\nCreature — Human Rogue\nWhen Parsed Sleuth enters, create a Clue token.\n" \
              "Whenever you draw a card, put a +1/+1 counter on Parsed Sleuth.\n1/1\n")
    sleuth = ResolvePermanent("Parsed Sleuth", owner: p1)
    clue = token("Clue")
    p1.add_mana(blue: 2)
    expect do
      p1.activate_ability(ability: clue.activated_abilities.first) { _1.pay_mana(generic: { blue: 2 }) }
      game.stack.resolve!
    end.to change { p1.hand.count }.by(1)
    game.tick!
    expect(sleuth.power).to eq(2)
  end

  it "makes creature spells cost {1} less, not other spells" do
    load_card("Parsed Grove {1}{G}\nEnchantment\nCreature spells you cast cost {1} less to cast.\n")
    ResolvePermanent("Parsed Grove", owner: p1)
    go_to_main_phase!

    creature = p1.prepare_cast(card: Card("Wood Elves", owner: p1))
    expect([creature.mana_cost.generic, creature.mana_cost.green]).to eq([1, 1])
    sorcery = p1.prepare_cast(card: Card("Rampant Growth", owner: p1))
    expect(sorcery.mana_cost.generic).to eq(1)
  end
end
