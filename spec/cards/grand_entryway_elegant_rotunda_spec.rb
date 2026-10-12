# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GrandEntrywayElegantRotunda do
  include_context "two player game"

  before { go_to_main_phase! }

  def glimmers = p1.creatures.select { _1.type?("Glimmer") }

  context "Grand Entryway" do
    it "creates a 1/1 white Glimmer enchantment creature token when it is cast" do
      card = Card("Grand Entryway Elegant Rotunda", owner: p1)
      p1.hand.add(card)
      p1.add_mana(white: 2)
      p1.cast(card: card, door: :left) { |a| a.pay_mana(generic: { white: 1 }, white: 1) }
      game.stack.resolve!
      game.settle!

      expect(glimmers.size).to eq(1)
      expect(glimmers.first.power).to eq(1)
      expect(glimmers.first.toughness).to eq(1)
      expect(glimmers.first.types).to include(Magic::Types::Enchantment)
    end

    it "creates a Glimmer when unlocked later" do
      room = ResolvePermanent("Grand Entryway Elegant Rotunda", doors: [:right])
      p1.add_mana(white: 2)
      p1.unlock_door(permanent: room, door: :left) { |a| a.pay_mana(generic: { white: 1 }, white: 1) }
      game.settle!

      expect(glimmers.size).to eq(1)
    end
  end

  context "Elegant Rotunda" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:other_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:third_bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "puts a +1/+1 counter on each of up to two target creatures" do
      room = ResolvePermanent("Grand Entryway Elegant Rotunda", doors: [:left])
      game.settle!
      p1.add_mana(white: 3)
      p1.unlock_door(permanent: room, door: :right) { |a| a.pay_mana(generic: { white: 2 }, white: 1) }
      game.settle!

      expect(game.choices.first).to be_a(described_class::ElegantRotunda::CountersChoice)
      game.resolve_choice!(targets: [bears, other_bears])

      expect(bears.power).to eq(3)
      expect(other_bears.power).to eq(3)
      expect(third_bears.power).to eq(2)
    end

    it "may target nothing" do
      room = ResolvePermanent("Grand Entryway Elegant Rotunda", doors: [:left])
      p1.add_mana(white: 3)
      p1.unlock_door(permanent: room, door: :right) { |a| a.pay_mana(generic: { white: 2 }, white: 1) }
      game.settle!
      game.resolve_choice!(targets: [])

      expect(bears.power).to eq(2)
    end
  end
end
