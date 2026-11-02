# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::GimlisAxe do
  include_context "two player game"

  let!(:axe) { ResolvePermanent("Gimlis Axe", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:jazal) { ResolvePermanent("Jazal Goldmane", owner: p1) } # legendary 4/4
  before { go_to_main_phase! }

  def equip(creature)
    p1.add_mana(colorless: 2)
    p1.activate_ability(ability: axe.activated_abilities.first) do |a|
      a.pay_mana(generic: { colorless: 2 })
      a.targeting(creature)
    end
    game.stack.resolve!
    game.tick!
  end

  it "is a {2}{R} Equipment" do
    expect(axe.card.mana_value).to eq(3)
    expect(axe.card).to be_a(Magic::Cards::Equipment)
  end

  it "has equip {2}" do
    ability = axe.activated_abilities.first
    expect(ability.costs.size).to eq(1)
    expect(ability.costs.first.cost[:generic]).to eq(2)
  end

  it "can only be equipped at sorcery speed" do
    go_to_main_phase_for!(p2)
    p1.add_mana(colorless: 2)

    expect do
      p1.activate_ability(ability: axe.activated_abilities.first) do |a|
        a.pay_mana(generic: { colorless: 2 })
        a.targeting(bears)
      end
    end.to raise_error(Magic::IllegalAction, /requirements to activate/)
  end

  it "gives a nonlegendary creature +3/+0 but not menace" do
    equip(bears)

    expect([bears.power, bears.toughness]).to eq([5, 2])
    expect(bears).not_to have_keyword(:menace)
  end

  it "gives a legendary creature +3/+0 and menace" do
    equip(jazal)

    expect([jazal.power, jazal.toughness]).to eq([7, 4])
    expect(jazal).to have_keyword(:menace)
  end

  it "does not buff other creatures" do
    equip(jazal)

    expect([bears.power, bears.toughness]).to eq([2, 2])
    expect(bears).not_to have_keyword(:menace)
  end

  it "loses menace when moved from a legendary to a nonlegendary creature" do
    equip(jazal)
    equip(bears)

    expect(jazal).not_to have_keyword(:menace)
    expect([jazal.power, jazal.toughness]).to eq([4, 4])
    expect(bears).not_to have_keyword(:menace)
    expect(bears.power).to eq(5)
  end

  it "loses the bonus and menace when the Axe leaves the battlefield" do
    equip(jazal)
    axe.destroy!
    game.settle!
    game.tick!

    expect(game.battlefield.permanents).not_to include(axe)
    expect([jazal.power, jazal.toughness]).to eq([4, 4])
    expect(jazal).not_to have_keyword(:menace)
  end
end
