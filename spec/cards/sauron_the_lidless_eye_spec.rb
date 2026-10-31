# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SauronTheLidlessEye do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_sauron
    p1.add_mana(black: 1, red: 1, green: 3)
    p1.cast(card: Card("Sauron The Lidless Eye", owner: p1)) do
      _1.pay_mana(black: 1, red: 1, generic: { green: 3 })
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary 4/4 Avatar Horror" do
    sauron = ResolvePermanent("Sauron The Lidless Eye", owner: p1)

    expect([sauron.power, sauron.toughness]).to eq([4, 4])
    expect(sauron.card).to be_legendary
    expect(sauron.type?("Avatar")).to be(true)
    expect(sauron.type?("Horror")).to be(true)
  end

  describe "enters trigger" do
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p2) }
    let!(:mine) { ResolvePermanent("Raging Goblin", owner: p1) }
    let!(:goblin) { ResolvePermanent("Raging Goblin", owner: p2) }

    before do
      bears.tap!
      cast_sauron
    end

    it "offers only creatures an opponent controls" do
      expect(game.choices.first.choices.to_a).to contain_exactly(bears, goblin)
    end

    it "steals the target, untaps it and gives it haste" do
      game.resolve_choice!(target: bears)
      game.settle!
      game.tick!

      expect(bears.controller).to eq(p1)
      expect(bears).not_to be_tapped
      expect(bears).to have_keyword(:haste)
      expect(goblin.controller).to eq(p2)
    end

    it "is mandatory" do
      game.skip_choice!
      game.settle!

      expect([bears, goblin].count { _1.controller == p1 }).to eq(1)
    end

    it "returns the creature at end of turn and loses haste" do
      game.resolve_choice!(target: bears)
      game.settle!
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(bears.controller).to eq(p2)
      expect(bears).not_to have_keyword(:haste)
    end
  end

  it "cannot target a hexproof creature" do
    big = ResolvePermanent("Gigantic Big Bear", owner: p2)
    bears = ResolvePermanent("Grizzly Bears", owner: p2)
    cast_sauron
    game.settle!

    expect(game.choices).to be_empty
    expect(big.controller).to eq(p2)
    expect(bears.controller).to eq(p1)
  end

  it "does nothing when the opponent has no creatures" do
    cast_sauron

    expect(game.choices).to be_empty
  end

  describe "rally ability" do
    let!(:sauron) { ResolvePermanent("Sauron The Lidless Eye", owner: p1) }
    let!(:mine) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

    def rally
      p1.add_mana(black: 1, red: 1, green: 1)
      p1.activate_ability(ability: sauron.activated_abilities.first) do
        _1.pay_mana(black: 1, red: 1, generic: { green: 1 })
      end
      game.stack.resolve!
      game.settle!
      game.tick!
    end

    it "gives creatures you control +2/+0 and drains each opponent for 2" do
      rally

      expect([sauron.power, sauron.toughness]).to eq([6, 4])
      expect([mine.power, mine.toughness]).to eq([4, 2])
      expect([theirs.power, theirs.toughness]).to eq([2, 2])
      expect(p2.life).to eq(18)
      expect(p1.life).to eq(20)
    end

    it "wears off at end of turn" do
      rally
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect([mine.power, mine.toughness]).to eq([2, 2])
    end

    it "needs the mana" do
      p1.add_mana(black: 1)

      expect do
        p1.activate_ability(ability: sauron.activated_abilities.first) do
          _1.pay_mana(black: 1, red: 1, generic: { green: 1 })
        end
      end.to raise_error(Magic::Costs::Mana::CannotPay)
    end
  end
end
