# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DiversionSpecialist do
  include_context "two player game"

  let!(:specialist) { ResolvePermanent("Diversion Specialist", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def activate!(sacrificing)
    p1.add_mana(red: 1)
    p1.activate_ability(ability: specialist.activated_abilities.first) do
      _1.pay_mana(generic: { red: 1 })
      _1.pay_sacrifice(sacrificing)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a 4/3 Human Warrior with menace" do
    expect([specialist.power, specialist.toughness]).to eq([4, 3])
    expect(specialist).to be_menace
  end

  it "sacrifices another creature to exile the top card, which you may play this turn" do
    top = p1.library.first
    activate!(bears)

    expect(bears.card.zone).to be_graveyard
    expect(top.zone).to be_exile
    expect(game.play_permissions.permits?(top, p1)).to be(true)
    expect(game.play_permissions.permits?(top, p2)).to be(false)
  end

  it "can sacrifice an enchantment" do
    enchantment = ResolvePermanent("Abundance", owner: p1)
    top = p1.library.first
    activate!(enchantment)

    expect(enchantment.card.zone).to be_graveyard
    expect(top.zone).to be_exile
  end

  it "can't sacrifice itself" do
    p1.add_mana(red: 1)
    expect do
      p1.activate_ability(ability: specialist.activated_abilities.first) do
        _1.pay_mana(generic: { red: 1 })
        _1.pay_sacrifice(specialist)
      end
    end.to raise_error(StandardError)
    expect(specialist.zone).to be_battlefield
  end

  it "ends the permission with the turn" do
    top = p1.library.first
    activate!(bears)
    game.next_turn

    expect(game.play_permissions.permits?(top, p1)).to be(false)
  end
end
