# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KrrikSonOfYawgmoth do
  include_context "two player game"

  before { go_to_main_phase! }

  def cast_krrik!(life_for_black:, mana:)
    p1.add_mana(**mana)
    krrik = Card("Krrik Son Of Yawgmoth", owner: p1)
    p1.cast(card: krrik) do |a|
      a.pay_life_for_black(life_for_black) if life_for_black.positive?
      a.pay_mana(generic: { colorless: 4 }, black: 3 - life_for_black)
    end
    game.stack.resolve!
    game.settle!
    p1.creatures.find { _1.name == "K'rrik, Son of Yawgmoth" }
  end

  it "is a 2/2 lifelinker" do
    krrik = ResolvePermanent("Krrik Son Of Yawgmoth", owner: p1)
    expect([krrik.power, krrik.toughness]).to eq([2, 2])
    expect(krrik).to be_lifelink
  end

  it "can be cast with life in place of its black mana" do
    krrik = cast_krrik!(life_for_black: 3, mana: { colorless: 4 })

    expect(krrik).not_to be_nil
    expect(p1.life).to eq(20 - 6)
  end

  it "can be cast with black mana and no life" do
    krrik = cast_krrik!(life_for_black: 0, mana: { colorless: 4, black: 3 })

    expect(krrik).not_to be_nil
    expect(p1.life).to eq(20)
  end

  context "on the battlefield" do
    let!(:krrik) { ResolvePermanent("Krrik Son Of Yawgmoth", owner: p1) }

    it "lets any black spell be cast paying 2 life for each {B}" do
      p1.add_mana(black: 1)
      p1.cast(card: Card("Doom Blade", owner: p1)) do |a|
        a.pay_life_for_black(1)
        a.pay_mana(generic: { black: 1 })
        a.targeting(ResolvePermanent("Grizzly Bears", owner: p2))
      end

      expect(p1.life).to eq(18)
    end

    context "with an activated ability that costs {B}" do
      let!(:vault) { ResolvePermanent("Spymaster's Vault", owner: p1) }
      let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

      before { vault.untap! }

      it "lets the {B} be paid with 2 life" do
        p1.activate_ability(ability: vault.activated_abilities.last) do |a|
          a.pay_life_for_black(1)
          a.targeting(bears)
        end

        expect(p1.life).to eq(18)
        expect(vault).to be_tapped
        expect(game.stack).not_to be_empty
      end

      it "still lets the {B} be paid with mana" do
        p1.add_mana(black: 1)
        p1.activate_ability(ability: vault.activated_abilities.last) do |a|
          a.pay_mana(black: 1)
          a.targeting(bears)
        end

        expect(p1.life).to eq(20)
      end

      it "does not let an opponent's ability use it" do
        opposing_vault = ResolvePermanent("Spymaster's Vault", owner: p2)
        opposing_bears = ResolvePermanent("Grizzly Bears", owner: p2)
        opposing_vault.untap!

        expect {
          p2.activate_ability(ability: opposing_vault.activated_abilities.last) do |a|
            a.pay_life_for_black(1)
            a.targeting(opposing_bears)
          end
        }.to raise_error(/may pay with life/)
        expect(p2.life).to eq(20)
      end
    end

    it "gets a +1/+1 counter whenever its controller casts a black spell" do
      p1.add_mana(black: 2)
      p1.cast(card: Card("Doom Blade", owner: p1)) do |a|
        a.pay_mana(generic: { black: 1 }, black: 1)
        a.targeting(ResolvePermanent("Grizzly Bears", owner: p2))
      end
      game.settle!
      game.stack.resolve!
      game.settle!

      expect([krrik.power, krrik.toughness]).to eq([3, 3])
    end

    it "does not get a counter for a non-black spell" do
      p1.add_mana(red: 1)
      p1.cast(card: Card("Shock", owner: p1)) { |a| a.pay_mana(red: 1); a.targeting(p2) }
      game.settle!
      game.stack.resolve!

      expect(krrik.power).to eq(2)
    end
  end
end
