require "spec_helper"

RSpec.describe "Saga Lore Counters" do
  include_context "two player game"

  let(:p1_library) do
    10.times.map { Card("Island", owner: p1) }
  end

  let(:p2_library) do
    10.times.map { Card("Mountain", owner: p2) }
  end

  context "as a card" do
    let(:card) { Card("Battle For Bretagard") }

    it "adds a lore counter when it enters" do
      p1.add_mana(white: 2, green: 1)
      p1.cast(card: card) do
        _1.auto_pay_mana
      end

      game.stack.resolve!

      permanent = game.battlefield.by_name("Battle for Bretagard").first

      expect(permanent.counters.of_type(Magic::Counters::Lore).count).to eq(1)
      human_warrior = game.battlefield.by_name("Human Warrior")
      expect(human_warrior.count).to eq(1)

      game.next_turn
      game.next_turn

      turn_3 = game.current_turn

      turn_3.untap!
      turn_3.upkeep!
      turn_3.draw!
      turn_3.first_main!

      expect(permanent.counters.of_type(Magic::Counters::Lore).count).to eq(2)

      elf_warrior = game.battlefield.by_name("Elf Warrior")
      expect(elf_warrior.count).to eq(1)

      game.next_turn
      game.next_turn

      turn_5 = game.current_turn
      turn_5.untap!
      turn_5.upkeep!
      turn_5.draw!
      turn_5.first_main!

      expect(game.battlefield.by_name("Battle for Bretagard")).to be_empty
      expect(card.zone).to be_graveyard

      human_warrior = game.battlefield.by_name("Human Warrior").first
      elf_warrior = game.battlefield.by_name("Elf Warrior").first

      game.resolve_choice!(targets: [human_warrior, elf_warrior])

      expect(game.battlefield.by_name("Human Warrior").count).to eq(2)
      expect(game.battlefield.by_name("Elf Warrior").count).to eq(2)
    end
  end
end
