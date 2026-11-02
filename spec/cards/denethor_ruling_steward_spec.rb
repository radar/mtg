# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DenethorRulingSteward do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:denethor) { ResolvePermanent("Denethor Ruling Steward", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def soldiers(player) = player.creatures.select { _1.token? && _1.type?("Soldier") }

  def end_step(player = p1)
    game.notify!(Magic::Events::BeginningOfEndStep.new(active_player: player))
    game.settle!
  end

  def drain(sacrificing: bears)
    p1.add_mana(colorless: 2)
    p1.activate_ability(ability: denethor.activated_abilities.first) do |a|
      a.pay_mana(generic: { colorless: 2 })
      a.pay_sacrifice(sacrificing)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary 2/4 Human Noble" do
    expect([denethor.power, denethor.toughness]).to eq([2, 4])
    expect(denethor).to be_legendary
    expect(denethor.type?("Human")).to be(true)
    expect(denethor.type?("Noble")).to be(true)
  end

  describe "end step trigger" do
    it "creates a Human Soldier token if a creature died under your control this turn" do
      bears.destroy!
      game.settle!
      end_step

      expect(soldiers(p1).count).to eq(1)
      expect(soldiers(p1).first.type?("Human")).to be(true)
      expect(soldiers(p1).first.colors).to include(:white)
    end

    it "does not trigger if no creature died" do
      end_step
      expect(soldiers(p1)).to be_empty
      expect(game.choices).to be_empty
    end

    it "does not trigger if only an opponent's creature died" do
      ResolvePermanent("Grizzly Bears", owner: p2).destroy!
      game.settle!
      end_step
      expect(soldiers(p1)).to be_empty
    end

    it "does not trigger on the opponent's end step" do
      bears.destroy!
      game.settle!
      end_step(p2)
      expect(soldiers(p1)).to be_empty
    end

    it "counts a creature sacrificed to its own ability" do
      drain
      end_step
      expect(soldiers(p1).count).to eq(1)
    end
  end

  describe "drain ability" do
    it "makes each opponent lose 1 life and you gain 1 life, sacrificing another creature" do
      drain
      expect(p2.life).to eq(19)
      expect(p1.life).to eq(21)
      expect(bears.zone).not_to be_a(Magic::Zones::Battlefield)
      expect(p1.creatures).to include(denethor)
    end

    it "cannot sacrifice Denethor himself" do
      p1.add_mana(colorless: 2)
      expect do
        p1.activate_ability(ability: denethor.activated_abilities.first) do |a|
          a.pay_mana(generic: { colorless: 2 })
          a.pay_sacrifice(denethor)
        end
      end.to raise_error(StandardError)
    end

    it "needs {2}" do
      p1.add_mana(colorless: 1)
      expect do
        p1.activate_ability(ability: denethor.activated_abilities.first) do |a|
          a.pay_mana(generic: { colorless: 2 })
          a.pay_sacrifice(bears)
        end
      end.to raise_error(StandardError)
      expect(p2.life).to eq(20)
    end
  end
end
