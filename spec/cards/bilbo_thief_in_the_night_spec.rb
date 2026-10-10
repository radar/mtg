# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BilboThiefInTheNight do
  include_context "two player game"

  let!(:bilbo) { ResolvePermanent("Bilbo, Thief In The Night", owner: p1) }

  def attack_with_bilbo
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: bilbo, target: p2)
    current_turn.attackers_declared!
    game.settle!
  end

  it "is a 2/2" do
    expect([bilbo.power, bilbo.toughness]).to eq([2, 2])
  end

  describe "cost reduction" do
    it "makes a spell cast from the graveyard cost {1} less" do
      go_to_main_phase!
      stone = Card("Mind Stone", owner: p1)
      p1.graveyard.add(stone)
      p1.add_mana(colorless: 1)

      p1.cast(card: stone, by_effect: true) { |a| a.pay_mana(generic: { colorless: 1 }) }
      game.stack.resolve!

      expect(game.battlefield.controlled_by(p1).map(&:name)).to include("Mind Stone")
    end

    it "does not reduce a spell cast from your hand" do
      go_to_main_phase!
      stone = Card("Mind Stone", owner: p1)
      p1.hand.add(stone)
      p1.add_mana(colorless: 1)

      expect {
        p1.cast(card: stone) { |a| a.pay_mana(generic: { colorless: 1 }) }
      }.to raise_error(StandardError)
    end
  end

  describe "when it attacks" do
    it "lets you cast an artifact from your graveyard" do
      stone = Card("Mind Stone", owner: p1)
      p1.graveyard.add(stone)
      attack_with_bilbo

      choice = game.choices.find { _1.is_a?(described_class::CastChoice) }
      expect(choice.choices).to include(stone)

      p1.add_mana(colorless: 1)
      game.resolve_choice!(target: stone, payment: { generic: { colorless: 1 } })
      game.stack.resolve!

      expect(game.battlefield.controlled_by(p1).map(&:name)).to include("Mind Stone")
    end

    it "exiles an instant cast this way instead of putting it into your graveyard" do
      opt = Card("Opt", owner: p1)
      p1.graveyard.add(opt)
      attack_with_bilbo

      p1.add_mana(blue: 1)
      game.resolve_choice!(target: opt, payment: { blue: 1 })
      game.stack.resolve!
      game.settle!

      expect(game.exile.cards).to include(opt)
      expect(p1.graveyard.cards).not_to include(opt)
    end

    it "offers nothing when there is no artifact, instant or sorcery in your graveyard" do
      p1.graveyard.add(Card("Grizzly Bears", owner: p1))
      attack_with_bilbo

      expect(game.choices.select { _1.is_a?(described_class::CastChoice) }).to be_empty
    end
  end
end
