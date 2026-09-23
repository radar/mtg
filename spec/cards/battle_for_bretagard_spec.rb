# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Magic::Cards::BattleForBretagard do
  include_context "two player game"

  let(:card) { Card("Battle For Bretagard") }

  before do
    p1.hand.add(card)
    go_to_main_phase!
    p1.add_mana(white: 1, green: 2)
    p1.cast(card: card) do
      _1.pay_mana(white: 1, green: 1, generic: { green: 1 })
    end
    game.stack.resolve!
    game.tick!
  end

  let(:battle_for_bretagard) { game.battlefield.by_name("Battle for Bretagard").first }

  it "enters with a lore counter and triggers Chapter 1 (creates a Human Warrior token)" do
    expect(battle_for_bretagard.counters.of_type(Magic::Counters::Lore).count).to eq(1)

    human_warrior = game.battlefield.creatures.by_name("Human Warrior").first
    expect(human_warrior).to_not be_nil
    expect(human_warrior.power).to eq(1)
    expect(human_warrior.toughness).to eq(1)
    expect(human_warrior.colors).to eq([:white])
  end

  context "on the second turn" do
    before do
      2.times { game.next_turn }
      go_to_main_phase!
      game.stack.resolve!
      game.tick!
    end

    it "triggers Chapter 2 (creates an Elf Warrior token)" do
      expect(battle_for_bretagard.counters.of_type(Magic::Counters::Lore).count).to eq(2)

      elf_warrior = game.battlefield.creatures.by_name("Elf Warrior").first
      expect(elf_warrior).to_not be_nil
      expect(elf_warrior.power).to eq(1)
      expect(elf_warrior.toughness).to eq(1)
      expect(elf_warrior.colors).to eq([:green])
    end

    context "on the third turn" do
      let!(:saga_card) { battle_for_bretagard.card }

      before do
        2.times { game.next_turn }
        go_to_main_phase!
        game.stack.resolve!
        game.tick!
      end

      it "triggers Chapter 3 (copies tokens with different names) and sacrifices itself" do
        human_warrior = game.battlefield.creatures.by_name("Human Warrior").first
        elf_warrior = game.battlefield.creatures.by_name("Elf Warrior").first

        choice = game.choices.last
        expect(choice).to be_a(Magic::Choice::CopyTokens)
        expect(choice.choices).to contain_exactly(human_warrior, elf_warrior)

        game.resolve_choice!(targets: [human_warrior, elf_warrior])

        expect(game.battlefield.creatures.by_name("Human Warrior").count).to eq(2)
        expect(game.battlefield.creatures.by_name("Elf Warrior").count).to eq(2)
        expect(game.battlefield.creatures.by_name("Elf Warrior").map(&:controller)).to all(eq(p1))
        expect(saga_card.zone).to be_graveyard
      end

      it "does not copy two tokens with the same name" do
        ResolvePermanent("Elvish Mystic", owner: p1)
        elf_warriors = [game.battlefield.creatures.by_name("Elf Warrior").first]
        elf_warriors << Magic::Cards::BattleForBretagard::Chapter2::ElfWarriorToken.new(game: game, owner: p1).resolve!

        expect(game.choices.last.choices).not_to include(game.battlefield.by_name("Elvish Mystic").first)
        expect { game.resolve_choice!(targets: elf_warriors) }.to raise_error(ArgumentError, /different names/)
      end
    end
  end
end
