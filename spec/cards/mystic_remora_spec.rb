# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::MysticRemora do
  include_context "two player game"

  let!(:remora) { ResolvePermanent("Mystic Remora", owner: p1) }

  def upkeep
    game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p1))
    game.settle!
  end

  def age = remora.counters.count { _1.is_a?(Magic::Counters["age"]) }

  describe "cumulative upkeep {1}" do
    it "puts an age counter on it and asks for {1}" do
      upkeep

      expect(age).to eq(1)
      choice = game.choices.last
      expect(choice).to be_a(described_class::UpkeepChoice)
      expect(choice.payment_cost).to eq(generic: 1)
    end

    it "stays when the upkeep is paid" do
      p1.add_mana(green: 1)
      upkeep
      game.resolve_choice!(payment: { green: 1 })

      expect(p1.permanents).to include(remora)
    end

    it "is sacrificed when the upkeep isn't paid" do
      upkeep
      game.skip_choice!

      expect(p1.permanents).not_to include(remora)
    end

    it "costs {1} for each age counter" do
      p1.add_mana(green: 3)
      upkeep
      game.resolve_choice!(payment: { green: 1 })
      upkeep

      expect(age).to eq(2)
      expect(game.choices.last.payment_cost).to eq(generic: 2)
    end

    it "doesn't trigger on the opponent's upkeep" do
      game.notify!(Magic::Events::BeginningOfUpkeep.new(player: p2))
      game.settle!

      expect(age).to eq(0)
    end
  end

  describe "the opponent's noncreature spell" do
    def cast_path_by_p2
      target = ResolvePermanent("Grizzly Bears", owner: p1)
      spell = Card("Path To Exile", owner: p2)
      p2.hand.add(spell)
      p2.add_mana(white: 1)
      p2.cast(card: spell) do |action|
        action.targeting(target)
        action.pay_mana(white: 1)
      end
      game.settle!
    end

    it "draws a card for you when the opponent doesn't pay {4}" do
      cast_path_by_p2
      choice = game.choices.last
      expect(choice).to be_a(described_class::PayOrDrawChoice)
      expect(choice.player).to eq(p2)

      expect { game.skip_choice! }.to change { p1.hand.count }.by(1)
    end

    it "draws nothing when the opponent pays {4}" do
      cast_path_by_p2
      p2.add_mana(red: 4)

      expect { game.resolve_choice!(payment: { red: 4 }) }.not_to change { p1.hand.count }
      expect(p2.mana_pool[:red]).to eq(0)
    end

    it "doesn't trigger for a creature spell" do
      spell = Card("Grizzly Bears", owner: p2)
      p2.hand.add(spell)
      p2.add_mana(green: 2)
      go_to_main_phase_for!(p2)
      p2.cast(card: spell) { |action| action.pay_mana(generic: { green: 1 }, green: 1) }

      expect(game.choices).to be_empty
    end

    it "doesn't trigger for your own spell" do
      spell = Card("Path To Exile", owner: p1)
      target = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.hand.add(spell)
      p1.add_mana(white: 1)
      p1.cast(card: spell) { |action| action.targeting(target).pay_mana(white: 1) }

      expect(game.choices).to be_empty
    end
  end
end
