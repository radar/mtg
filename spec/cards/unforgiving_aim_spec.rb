# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::UnforgivingAim do
  include_context "two player game"

  let(:card) { Card("Unforgiving Aim", owner: p1) }

  def cast_mode(index, target = nil)
    p1.hand.add(card)
    p1.add_mana(green: 3)
    p1.cast(card:) do |action|
      action.choose_mode(card.modes[index]) { |mode| mode.targeting(target) if target }
      action.pay_mana(generic: { green: 2 }, green: 1)
    end
    game.stack.resolve!
  end

  it "destroys a creature with flying" do
    flyer = ResolvePermanent("Shinestriker", owner: p2)
    game.tick!
    cast_mode(0, flyer)

    expect(flyer.card.zone).to be_graveyard
  end

  it "cannot target a creature without flying with the first mode" do
    ground = ResolvePermanent("Grizzly Bears", owner: p2)

    expect(card.modes[0].new(game:, card:).target_choices).not_to include(ground)
  end

  it "destroys an enchantment" do
    aura = ResolvePermanent("Clachan Festival", owner: p2)
    cast_mode(1, aura)

    expect(aura.card.zone).to be_graveyard
  end

  it "creates a 2/2 black and green Elf token" do
    cast_mode(2)
    elf = p1.creatures.find { _1.name == "Elf" }

    expect([elf.power, elf.toughness, elf.colors]).to eq([2, 2, [:black, :green]]).or eq([2, 2, %i[green black]])
  end
end
