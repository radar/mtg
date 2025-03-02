require 'spec_helper'

RSpec.describe Magic::Cards::BattleForBretagard do
  include_context "two player game"

  let(:card) { Card("Battle For Bretagard") }

  it "gets a counter + creates a human warrior when it is cast" do
    p1.add_mana(white: 1, green: 2)

    p1.cast(card: card) do
      _1.pay_mana(white: 1, green: 1, generic: { green: 1 })
    end

    game.stack.resolve!
    game.tick!

    battle_for_bretagard = game.battlefield.by_name("Battle for Bretagard").first
    expect(battle_for_bretagard.counters.of_type(Magic::Counters::Lore).count).to eq(1)

    human_warrior = game.battlefield.creatures.by_name("Human Warrior").first
    expect(human_warrior).to_not be_nil
    expect(human_warrior.power).to eq(1)
    expect(human_warrior.toughness).to eq(1)
    expect(human_warrior.colors).to eq([:white])

    battle_for_bretagard.trigger_effect(:add_counter, counter_type: Magic::Counters::Lore, target: battle_for_bretagard)

    game.stack.resolve!
    game.tick!

    elf_warrior = game.battlefield.creatures.by_name("Elf Warrior").first
    expect(elf_warrior).to_not be_nil
    expect(elf_warrior.power).to eq(1)
    expect(elf_warrior.toughness).to eq(1)
    expect(elf_warrior.colors).to eq([:green])

    battle_for_bretagard.trigger_effect(:add_counter, counter_type: Magic::Counters::Lore, target: battle_for_bretagard)

    game.stack.resolve!
    game.tick!

    expect(human_warrior).to have_keyword(:deathtouch)
    expect(elf_warrior).to have_keyword(:deathtouch)

    expect(battle_for_bretagard.card.zone).to be_graveyard



  end
end
