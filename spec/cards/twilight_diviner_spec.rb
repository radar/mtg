# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::TwilightDiviner do
  include_context "two player game"

  it "is a 3/3 Elf Cleric" do
    diviner = ResolvePermanent("Twilight Diviner", owner: p1)
    game.skip_choice!
    expect([diviner.power, diviner.toughness]).to eq([3, 3])
    expect(diviner).to be_type("Elf")
    expect(diviner).to be_type("Cleric")
  end

  it "surveils 2 when it enters" do
    ResolvePermanent("Twilight Diviner", owner: p1)
    choice = game.choices.last
    expect(choice).to be_a(Magic::Choice::Surveil)
    expect(choice.amount).to eq(2)

    top_two = p1.library.first(2)
    game.resolve_choice!(graveyard: top_two)
    expect(top_two.map(&:zone)).to all(be_graveyard)
  end

  context "with Twilight Diviner on the battlefield" do
    let!(:diviner) { ResolvePermanent("Twilight Diviner", owner: p1) }

    before do
      game.skip_choice!
      go_to_main_phase!
    end

    def rise_again(card)
      p1.graveyard.add(card)
      p1.add_mana(black: 5)
      p1.cast(card: Card("Rise Again")) do
        _1.auto_pay_mana
        _1.targeting(card)
      end
      game.stack.resolve!
    end

    it "creates a token copy of a creature that enters from your graveyard" do
      rise_again(Card("Grizzly Bears"))

      bears = p1.creatures.by_name("Grizzly Bears")
      expect(bears.count).to eq(2)
      expect(bears.count(&:token?)).to eq(1)
    end

    it "triggers only once each turn" do
      rise_again(Card("Grizzly Bears"))
      rise_again(Card("Wood Elves"))

      expect(p1.creatures.by_name("Wood Elves").count).to eq(1)
    end

    it "triggers again on a later turn" do
      rise_again(Card("Grizzly Bears"))
      current_turn.end!
      current_turn.cleanup!
      go_to_main_phase_for!(p2)
      go_to_main_phase_for!(p1)
      rise_again(Card("Wood Elves"))

      expect(p1.creatures.by_name("Wood Elves").count).to eq(2)
    end

    it "doesn't copy a creature cast from your hand" do
      bears = Card("Grizzly Bears")
      p1.hand.add(bears)
      p1.add_mana(green: 2)
      p1.cast(card: bears) { _1.auto_pay_mana }
      game.stack.resolve!

      expect(p1.creatures.by_name("Grizzly Bears").count).to eq(1)
    end

    it "doesn't copy an opponent's creature entering from their graveyard" do
      card = Card("Grizzly Bears", owner: p2)
      p2.graveyard.add(card)
      card.resolve!

      expect(game.battlefield.creatures.by_name("Grizzly Bears").count).to eq(1)
    end
  end
end
