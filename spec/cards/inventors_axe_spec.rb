# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::InventorsAxe do
  include_context "two player game"

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let(:axe_card) { Card("Inventor's Axe", owner: p1) }

  def cast_axe
    p1.hand.add(axe_card)
    p1.add_mana(red: 1)
    p1.cast(card: axe_card) { |a| a.pay_mana(red: 1) }
    game.stack.resolve!
    game.settle!
  end

  def axe = p1.permanents.find { _1.name == "Inventor's Axe" }

  it "has flash: it can be cast outside a main phase" do
    expect(axe_card).to be_flash
    cast_axe

    expect(axe).not_to be_nil
  end

  it "gives you two energy when it enters" do
    cast_axe

    expect(p1.energy).to eq(2)
  end

  it "attaches to the only creature you control when it enters" do
    cast_axe

    expect(axe.attached_to).to eq(bears)
  end

  it "lets you choose which creature to attach to" do
    other = ResolvePermanent("Grizzly Bears", owner: p1)
    ResolvePermanent("Grizzly Bears", owner: p2)
    cast_axe
    game.resolve_choice!(target: other)
    game.settle!

    expect(axe.attached_to).to eq(other)
    expect(other.power).to eq(4)
    expect(bears.power).to eq(2)
  end

  it "doesn't offer an opponent's creature" do
    opp = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_axe

    expect(axe.attached_to).to eq(bears)
    expect(opp.power).to eq(2)
  end

  it "enters unattached with no creature to attach to" do
    bears.destroy!
    game.settle!
    cast_axe

    expect(axe).not_to be_nil
    expect(axe.attached_to).to be_nil
    expect(p1.energy).to eq(2)
  end

  it "gives equipped creature +2/+0" do
    cast_axe
    game.tick!

    expect([bears.power, bears.toughness]).to eq([4, 2])
  end

  context "equip -- pay {E}{E}" do
    let!(:other) { ResolvePermanent("Grizzly Bears", owner: p1) }

    before do
      go_to_main_phase!
      cast_axe
      game.resolve_choice!(target: bears)
      game.settle!
    end

    def equip(target)
      p1.activate_ability(ability: axe.activated_abilities.first) { _1.targeting(target) }
      game.stack.resolve!
      game.tick!
    end

    it "moves to another creature by paying two energy" do
      equip(other)

      expect(p1.energy).to eq(0)
      expect(axe.attached_to).to eq(other)
      expect([other.power, bears.power]).to eq([4, 2])
    end

    it "can't be activated without two energy" do
      p1.pay_energy!(1)

      expect { equip(other) }.to raise_error(RuntimeError, /can't pay 2 \{E\}/)
      expect(axe.attached_to).to eq(bears)
    end
  end
end
