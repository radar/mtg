# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::SpymastersVault do
  include_context "two player game"

  before { go_to_main_phase! }

  it "enters tapped without a Swamp" do
    vault = ResolvePermanent("Spymaster's Vault", owner: p1)

    expect(vault).to be_tapped
  end

  it "enters untapped with a Swamp" do
    ResolvePermanent("Swamp", owner: p1)
    vault = ResolvePermanent("Spymaster's Vault", owner: p1)

    expect(vault).not_to be_tapped
  end

  it "taps for black mana" do
    ResolvePermanent("Swamp", owner: p1)
    vault = ResolvePermanent("Spymaster's Vault", owner: p1)

    p1.activate_ability(ability: vault.activated_abilities.first)

    expect(p1.mana_pool[:black]).to eq(1)
  end

  context "connive ability" do
    let!(:swamp) { ResolvePermanent("Swamp", owner: p1) }
    let!(:vault) { ResolvePermanent("Spymaster's Vault", owner: p1) }
    let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }
    let!(:victim) { ResolvePermanent("Grizzly Bears", owner: p2) }

    def activate(target)
      p1.add_mana(black: 1)
      p1.activate_ability(ability: vault.activated_abilities.last) do |a|
        a.pay_mana(black: 1)
        a.targeting(target)
      end
      game.stack.resolve!
    end

    it "can't target a creature an opponent controls" do
      expect { activate(victim) }.to raise_error(/Invalid target/)
    end

    it "connives 0 when no creature died" do
      hand_size = p1.hand.count

      activate(bears)

      expect(p1.hand.count).to eq(hand_size)
      expect(game.choices).to be_empty
      expect(bears.power).to eq(2)
    end

    it "connives X where X is the creatures that died this turn" do
      victim.destroy!
      game.settle!
      spell = Card("Grizzly Bears", owner: p1)
      p1.hand.add(spell)
      hand_size = p1.hand.count

      activate(bears)

      expect(p1.hand.count).to eq(hand_size + 1)
      expect(game.choices.size).to eq(1)

      game.resolve_choice!(card: spell)

      game.settle!

      expect(bears.power).to eq(3)
    end
  end
end
