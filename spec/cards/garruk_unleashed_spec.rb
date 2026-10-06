# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GarrukUnleashed do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:garruk) { ResolvePermanent("Garruk, Unleashed", owner: p1) }

  def activate(index, &block)
    p1.activate_loyalty_ability(ability: garruk.loyalty_abilities[index], &block)
    game.stack.resolve!
    game.settle!
  end

  it "enters with 4 loyalty" do
    expect(garruk.loyalty).to eq(4)
  end

  context "+1" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

    it "gives up to one target creature +3/+3 and trample until end of turn" do
      activate(0)
      game.resolve_choice!(target: bears)
      game.tick!

      expect(garruk.loyalty).to eq(5)
      expect([bears.power, bears.toughness]).to eq([5, 5])
      expect(bears.has_keyword?(Magic::Cards::Keywords::TRAMPLE)).to eq(true)
    end

    it "can target no creature" do
      activate(0)
      game.skip_choice!
      game.tick!

      expect(garruk.loyalty).to eq(5)
      expect([bears.power, bears.toughness]).to eq([2, 2])
    end
  end

  context "-2" do
    it "creates a 3/3 Beast and keeps loyalty at 2 when no opponent controls more creatures" do
      activate(1)

      beast = p1.creatures.by_name("Beast").first
      expect([beast.power, beast.toughness]).to eq([3, 3])
      expect(garruk.loyalty).to eq(2)
    end

    it "puts a loyalty counter on Garruk if an opponent controls more creatures" do
      3.times { ResolvePermanent("Grizzly Bears", owner: p2) }
      activate(1)

      expect(p1.creatures.count).to eq(1)
      expect(garruk.loyalty).to eq(3)
    end
  end

  context "-7" do
    def p1_library
      [*Array.new(7) { Card("Forest") }, Card("Island"), Card("Grizzly Bears"), Card("Forest"), Card("Forest")]
    end

    before { garruk.change_loyalty!(7) }

    it "gives you an emblem that searches for a creature at your end step" do
      activate(2)
      expect(game.emblems.count).to eq(1)

      current_turn.end!
      game.settle!
      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::SearchLibrary)
      game.resolve_choice!(targets: [choice.choices.first])

      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end
  end
end
