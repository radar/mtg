# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MarinaVendrell do
  include_context "two player game"

  def p1_library
    # Seven for the opening hand, then the top of the library: a mix of enchantments and other cards.
    7.times.map { Card("Forest") } + [
      Card("Grizzly Bears"),
      Card("Sanctum Of Calm Waters"),
      Card("Forest"),
      Card("Elderfang Venom"),
      Card("Forest"),
      Card("Island"),
      Card("Forest"),
      Card("Island"),
      Card("Island"),
    ]
  end

  context "when it enters" do
    before { go_to_main_phase! }

    it "puts every enchantment card from the top seven into your hand and the rest on the bottom" do
      library_size = p1.library.count
      top_seven = p1.library.first(7)
      marina = ResolvePermanent("Marina Vendrell", owner: p1)
      game.settle!

      expect(marina).to be_creature
      enchantments = top_seven.select(&:enchantment?)
      expect(enchantments.size).to eq(2)
      expect(p1.hand.cards).to include(*enchantments)
      expect(p1.library.count).to eq(library_size - 2)
      expect(p1.library.to_a.last(5).map(&:name).sort).to eq(top_seven.reject(&:enchantment?).map(&:name).sort)
    end
  end

  context "the door ability" do
    let!(:marina) { ResolvePermanent("Marina Vendrell", owner: p1) }
    let!(:room) { ResolvePermanent("Funeral Room Awakening Hall", owner: p1, doors: [:left]) }

    before { go_to_main_phase! }

    it "locks or unlocks a door of a Room you control, tapping Marina" do
      p1.activate_ability(ability: marina.activated_abilities.first)
      game.stack.resolve!
      game.resolve_choice!(door: game.choices.last.choices.find { _1.name == "Awakening Hall" })

      expect(room.card).to be_fully_unlocked
      expect(marina).to be_tapped
    end

    it "is activated only as a sorcery" do
      game.next_turn
      go_to_main_phase!

      expect { p1.activate_ability(ability: marina.activated_abilities.first) }.to raise_error(StandardError)
    end
  end
end
