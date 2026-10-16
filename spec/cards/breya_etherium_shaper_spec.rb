# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::BreyaEtheriumShaper do
  include_context "two player game"

  let!(:breya) { ResolvePermanent("Breya Etherium Shaper", owner: p1) }

  def thopters(player = p1) = player.creatures.select { _1.name == "Thopter" }

  def activate(index, player: p1, sacrifice:, target: nil)
    player.add_mana(red: 2)
    player.activate_ability(ability: breya.activated_abilities[index]) do |action|
      action.targeting(target) if target
      action.pay_mana(generic: { red: 2 })
      action.pay_sacrifice(sacrifice)
    end
    game.stack.resolve!
    game.settle!
  end

  it "is a legendary 4/4 Human artifact creature" do
    expect([breya.power, breya.toughness]).to eq([4, 4])
    expect(breya).to be_artifact
    expect(breya.type?("Human")).to be(true)
    expect(breya.type?("Legendary")).to be(true)
  end

  describe "enters trigger" do
    it "creates two 1/1 blue flying Thopter artifact creature tokens" do
      cast = Card("Breya Etherium Shaper", owner: p1)
      p1.hand.add(cast)
      go_to_main_phase!
      p1.add_mana(white: 1, blue: 1, black: 1, red: 1)
      p1.cast(card: cast) { |a| a.pay_mana(white: 1, blue: 1, black: 1, red: 1) }
      game.stack.resolve!
      game.settle!

      expect(thopters.count).to eq(2)
      thopters.each do |t|
        expect([t.power, t.toughness]).to eq([1, 1])
        expect(t).to be_artifact
        expect(t).to have_keyword(:flying)
        expect(t.colors).to eq([:blue])
      end
    end
  end

  describe "{2}, sacrifice two artifacts" do
    let!(:ring) { ResolvePermanent("Sol Ring", owner: p1) }
    let!(:ring2) { ResolvePermanent("Sol Ring", owner: p1) }

    it "deals 3 damage to target player" do
      activate(0, sacrifice: [ring, ring2], target: p2)

      expect(p2.life).to eq(17)
      expect(p1.artifacts).not_to include(ring, ring2)
      expect(p1.artifacts).to include(breya)
    end

    it "deals 3 damage to target planeswalker" do
      walker = ResolvePermanent("Ajani, Outland Chaperone", owner: p2)
      before = walker.loyalty
      activate(0, sacrifice: [ring, ring2], target: walker)

      expect(before).to be >= 1
      expect(p2.life).to eq(20)
      expect(walker.loyalty).to eq([before - 3, 0].max)
    end

    it "can't damage a creature" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      p1.add_mana(red: 2)
      expect {
        p1.activate_ability(ability: breya.activated_abilities[0]) do |action|
          action.targeting(bears)
          action.pay_mana(generic: { red: 2 })
          action.pay_sacrifice([ring, ring2])
        end
      }.to raise_error(RuntimeError, /Invalid target/)
    end

    it "gives target creature -4/-4 until end of turn" do
      bears = ResolvePermanent("Grizzly Bears", owner: p2)
      activate(1, sacrifice: [ring, ring2], target: bears)

      expect(p2.creatures).not_to include(bears)
      expect(p2.graveyard.cards.map(&:name)).to include("Grizzly Bears")
    end

    it "shrinks a big creature only until end of turn" do
      bear = ResolvePermanent("Gigantic Big Bear", owner: p1)
      activate(1, sacrifice: [ring, ring2], target: bear)
      expect([bear.power, bear.toughness]).to eq([6, 3])

      current_turn.end!
      current_turn.cleanup!
      game.tick!
      expect([bear.power, bear.toughness]).to eq([10, 7])
    end

    it "gains you 5 life" do
      activate(2, sacrifice: [ring, ring2])

      expect(p1.life).to eq(25)
    end

    it "can sacrifice Breya herself as one of the artifacts" do
      activate(2, sacrifice: [breya, ring])

      expect(p1.life).to eq(25)
      expect(p1.graveyard.cards.map(&:name)).to include("Breya, Etherium Shaper")
    end

    it "needs exactly two artifacts" do
      p1.add_mana(red: 2)
      expect {
        p1.activate_ability(ability: breya.activated_abilities[2]) do |action|
          action.pay_mana(generic: { red: 2 })
          action.pay_sacrifice([ring])
        end
      }.to raise_error(RuntimeError, /Sacrifice exactly two/)
    end

    it "can't sacrifice a non-artifact" do
      bears = ResolvePermanent("Grizzly Bears", owner: p1)
      p1.add_mana(red: 2)
      expect {
        p1.activate_ability(ability: breya.activated_abilities[2]) do |action|
          action.pay_mana(generic: { red: 2 })
          action.pay_sacrifice([ring, bears])
        end
      }.to raise_error(RuntimeError, /Sacrifice exactly two/)
    end

    it "needs {2}" do
      p1.add_mana(red: 1)
      expect {
        p1.activate_ability(ability: breya.activated_abilities[2]) do |action|
          action.pay_mana(generic: { red: 2 })
          action.pay_sacrifice([ring, ring2])
        end
      }.to raise_error(Magic::Costs::Mana::CannotPay)
    end

    it "can't be activated by the opponent" do
      p2.add_mana(red: 2)
      expect {
        p2.activate_ability(ability: breya.activated_abilities[2]) do |action|
          action.pay_mana(generic: { red: 2 })
          action.pay_sacrifice([ring, ring2])
        end
      }.to raise_error(Magic::IllegalAction, /does not control/)
      expect(p1.life).to eq(20)
    end
  end

  it "can't target a hexproof creature with the -4/-4 mode" do
    bear = ResolvePermanent("Gigantic Big Bear", owner: p2)
    ring = ResolvePermanent("Sol Ring", owner: p1)
    p1.add_mana(red: 2)
    expect {
      p1.activate_ability(ability: breya.activated_abilities[1]) do |action|
        action.targeting(bear)
        action.pay_mana(generic: { red: 2 })
        action.pay_sacrifice([breya, ring])
      end
    }.to raise_error(RuntimeError, /Invalid target/)
  end
end
