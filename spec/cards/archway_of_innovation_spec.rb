# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ArchwayOfInnovation do
  include_context "two player game"

  before { go_to_main_phase! }

  describe "enters tapped unless you control an Island" do
    it "enters tapped with no Island" do
      expect(ResolvePermanent("Archway Of Innovation", owner: p1)).to be_tapped
    end

    it "enters untapped with an Island" do
      ResolvePermanent("Island", owner: p1)

      expect(ResolvePermanent("Archway Of Innovation", owner: p1)).not_to be_tapped
    end
  end

  describe "abilities" do
    let!(:island) { ResolvePermanent("Island", owner: p1) }
    let!(:archway) { ResolvePermanent("Archway Of Innovation", owner: p1) }
    let!(:ornithopter) { ResolvePermanent("Rakdos Signet", owner: p1) }
    let(:bears) { Card("Grizzly Bears", owner: p1) } # {1}{G}

    it "taps for {U}" do
      p1.activate_ability(ability: archway.activated_abilities.first)

      expect(p1.mana_pool[:blue]).to eq(1)
    end

    it "gives the next spell improvise" do
      p1.add_mana(blue: 1)
      p1.activate_ability(ability: archway.activated_abilities.last) { |a| a.pay_mana(blue: 1) }
      game.stack.resolve!
      p1.hand.add(bears)
      p1.add_mana(green: 1)

      p1.cast(card: bears) do |action|
        action.improvise(ornithopter)
        action.pay_mana(green: 1)
      end
      game.stack.resolve!

      expect(ornithopter).to be_tapped
      expect(p1.creatures.map(&:name)).to include("Grizzly Bears")
    end

    it "does not give improvise without the ability" do
      p1.hand.add(bears)
      action = cast_action_as(:normal, card: bears, player: p1)

      expect { action.improvise(ornithopter) }.to raise_error(/does not have improvise/)
    end

    it "only applies to the next spell" do
      p1.add_mana(blue: 1)
      p1.activate_ability(ability: archway.activated_abilities.last) { |a| a.pay_mana(blue: 1) }
      game.stack.resolve!
      p1.hand.add(bears)
      p1.add_mana(green: 2)
      p1.cast(card: bears) { |a| a.pay_mana(generic: { green: 1 }, green: 1) }
      game.stack.resolve!
      second = Card("Grizzly Bears", owner: p1)
      p1.hand.add(second)
      action = cast_action_as(:normal, card: second, player: p1)

      expect { action.improvise(ornithopter) }.to raise_error(/does not have improvise/)
    end
  end
end
