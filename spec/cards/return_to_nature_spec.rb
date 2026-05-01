# frozen_string_literal: true
require "spec_helper"

RSpec.describe Magic::Cards::ReturnToNature do
  include_context "two player game"

  let(:return_to_nature) { Card("Return To Nature") }

  it "destroys target artifact" do
    great_furnace = ResolvePermanent("Great Furnace", owner: p2)

    mode_class = return_to_nature.modes[0]

    p1.add_mana(green: 1)
    p1.cast(card: return_to_nature) do
      _1.choose_mode(mode_class) do |mode|
        mode.targeting(great_furnace)
      end
      _1.auto_pay_mana
    end

    game.stack.resolve!

    expect(great_furnace.zone).to be_nil
    expect(great_furnace.card.zone).to be_graveyard
  end

  it "destroys target enchantment" do
    griffin_aerie = ResolvePermanent("Griffin Aerie", owner: p2)

    mode_class = return_to_nature.modes[1]

    p1.add_mana(green: 1)
    p1.cast(card: return_to_nature) do
      _1.choose_mode(mode_class) do |mode|
        mode.targeting(griffin_aerie)
      end
      _1.auto_pay_mana
    end

    game.stack.resolve!

    expect(griffin_aerie.zone).to be_nil
    expect(griffin_aerie.card.zone).to be_graveyard
  end

  it "exiles target card from a graveyard" do
    wood_elves = Card("Wood Elves", owner: p2)
    wood_elves.move_to_graveyard!

    mode_class = return_to_nature.modes[2]

    p1.add_mana(green: 1)
    p1.cast(card: return_to_nature) do
      _1.choose_mode(mode_class) do |mode|
        mode.targeting(wood_elves)
      end
      _1.auto_pay_mana
    end

    game.stack.resolve!

    expect(wood_elves.zone).to be_exile
    expect(p2.graveyard).not_to include(wood_elves)
  end
end
