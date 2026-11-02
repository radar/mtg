# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::EowynLadyOfRohan do
  include_context "two player game"

  let!(:eowyn) { ResolvePermanent("Eowyn Lady Of Rohan", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
  let!(:opp_bears) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def begin_combat(player = p1)
    go_to_main_phase_for!(player)
    current_turn.beginning_of_combat!
    game.settle!
  end

  def equip(equipment, creature, mana)
    p1.add_mana(colorless: mana)
    p1.activate_ability(ability: equipment.activated_abilities.first) do |a|
      a.targeting(creature)
      a.pay_mana(generic: { colorless: mana })
    end
    game.stack.resolve!
    game.tick!
  end

  it "is a legendary 2/4 Human Noble" do
    expect(eowyn.legendary?).to be true
    expect(eowyn.type?("Human")).to be true
    expect(eowyn.type?("Noble")).to be true
    expect([eowyn.power, eowyn.toughness]).to eq([2, 4])
  end

  describe "at the beginning of combat on your turn" do
    it "grants first strike to an unequipped target when chosen" do
      begin_combat
      game.resolve_choice!(target: bears)
      game.resolve_choice!(keyword: :first_strike)
      game.tick!

      expect(bears).to have_keyword(:first_strike)
      expect(bears).not_to have_keyword(:vigilance)
      expect(eowyn).not_to have_keyword(:first_strike)
    end

    it "grants vigilance to an unequipped target when chosen" do
      begin_combat
      game.resolve_choice!(target: bears)
      game.resolve_choice!(keyword: :vigilance)
      game.tick!

      expect(bears).to have_keyword(:vigilance)
      expect(bears).not_to have_keyword(:first_strike)
    end

    it "takes first strike when the keyword choice is declined" do
      begin_combat
      game.resolve_choice!(target: bears)
      game.skip_choice!
      game.tick!

      expect(bears).to have_keyword(:first_strike)
      expect(bears).not_to have_keyword(:vigilance)
    end

    it "can target an opponent's creature" do
      begin_combat
      game.resolve_choice!(target: opp_bears)
      game.resolve_choice!(keyword: :vigilance)
      game.tick!

      expect(opp_bears).to have_keyword(:vigilance)
    end

    it "does not offer a hexproof opponent's creature" do
      big = ResolvePermanent("Gigantic Big Bear", owner: p2)
      begin_combat

      expect(game.choices.first.choices).to include(bears, opp_bears)
      expect(game.choices.first.choices).not_to include(big)
    end

    it "grants both first strike and vigilance to an equipped creature with no further choice" do
      sting = ResolvePermanent("Sting The Glinting Dagger", owner: p1)
      go_to_main_phase!
      equip(sting, bears, 1) # {2} equip, {1} less with Eowyn
      begin_combat
      game.resolve_choice!(target: bears)
      game.tick!

      expect(game.choices).to be_empty
      expect(bears).to have_keyword(:first_strike)
      expect(bears).to have_keyword(:vigilance)
    end

    it "checks whether the creature is equipped on resolution" do
      sting = ResolvePermanent("Sting The Glinting Dagger", owner: p1)
      go_to_main_phase!
      equip(sting, bears, 1)
      begin_combat
      sting.destroy!
      game.settle!
      game.resolve_choice!(target: bears)

      expect(game.choices.first).to be_a(Magic::Cards::EowynLadyOfRohan::KeywordChoice)
    end

    it "wears off at end of turn" do
      begin_combat
      game.resolve_choice!(target: bears)
      game.resolve_choice!(keyword: :first_strike)
      game.tick!
      current_turn.end!
      current_turn.cleanup!
      game.tick!

      expect(bears).not_to have_keyword(:first_strike)
    end

    it "takes the first legal creature when the target choice is declined" do
      begin_combat
      expect(game.choices.first.choices).to include(eowyn)
      game.skip_choice!
      game.skip_choice!
      game.tick!

      expect(game.choices).to be_empty
    end

    it "does not trigger at the beginning of the opponent's combat" do
      begin_combat(p2)

      expect(game.choices).to be_empty
    end
  end

  describe "equip abilities you activate cost {1} less" do
    let!(:sting) { ResolvePermanent("Sting The Glinting Dagger", owner: p1) }
    before { go_to_main_phase! }

    it "lets you equip {2} for {1}" do
      equip(sting, bears, 1)

      expect(sting.attached_to).to eq(bears)
    end

    it "still costs {1}" do
      p1.add_mana(colorless: 1)
      expect do
        p1.activate_ability(ability: sting.activated_abilities.first) do |a|
          a.targeting(bears)
        end
      end.to raise_error(StandardError)
    end

    it "does not reduce equip costs without Eowyn" do
      eowyn.destroy!
      game.settle!
      game.tick!
      p1.add_mana(colorless: 1)

      expect do
        p1.activate_ability(ability: sting.activated_abilities.first) do |a|
          a.targeting(bears)
          a.pay_mana(generic: { colorless: 1 })
        end
      end.to raise_error(Magic::Costs::Mana::CannotPay)
    end

    it "does not reduce the opponent's equip costs" do
      p2_sting = ResolvePermanent("Sting The Glinting Dagger", owner: p2)
      go_to_main_phase_for!(p2)
      p2.add_mana(colorless: 1)

      expect do
        p2.activate_ability(ability: p2_sting.activated_abilities.first) do |a|
          a.targeting(opp_bears)
          a.pay_mana(generic: { colorless: 1 })
        end
      end.to raise_error(Magic::Costs::Mana::CannotPay)
    end
  end
end
