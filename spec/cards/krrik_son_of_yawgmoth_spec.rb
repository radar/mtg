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
