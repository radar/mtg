# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::PitilessFists do
  include_context "two player game"

  let!(:elves) { ResolvePermanent("Wood Elves", owner: p1) }

  before { go_to_main_phase! }

  def cast_fists(target = elves)
    p1.add_mana(green: 4)
    p1.cast(card: Card("Pitiless Fists")) do
      _1.auto_pay_mana
      _1.targeting(target)
    end
    game.stack.resolve!
  end

  it "can only enchant a creature you control" do
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    expect(Card("Pitiless Fists").target_choices).to include(elves)
    expect(Card("Pitiless Fists").target_choices).not_to include(bears)
  end

  it "gives the enchanted creature +2/+2" do
    cast_fists
    game.tick!
    expect([elves.power, elves.toughness]).to eq([3, 3])
  end

  context "with a creature an opponent controls" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

    it "has the enchanted creature fight it when the Aura enters" do
      cast_fists
      expect(game.choices.last.choice_amount).to eq(0..1)
      game.resolve_choice!(target: bears)
      game.tick!

      expect(bears.card.zone).to be_graveyard
      expect(elves.damage).to eq(2)
      expect(elves.zone).to be_battlefield
    end

    it "may fight nothing" do
      cast_fists
      game.skip_choice!
      game.tick!

      expect(bears.damage).to eq(0)
      expect(elves.damage).to eq(0)
    end
  end

  it "does nothing extra with no creature to fight" do
    cast_fists
    expect(game.choices).to be_empty
  end
end
