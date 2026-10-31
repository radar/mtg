# frozen_string_literal: true

require "spec_helper"

# {X} in the mana cost of an activated ability ("{X}{G}: ..."), chosen with `value_for_x:` on the activation.
RSpec.describe Magic::Actions::ActivateAbility, "with {X} in the cost" do
  include_context "two player game"

  let!(:source) { ResolvePermanent("Mind Stone", owner: p1) }
  let(:seen) { [] }
  let(:ability) do
    recorder = seen
    klass = Class.new(Magic::ActivatedAbility) do
      costs "{X}{G}"
      define_method(:resolve!) { |x:| recorder << x }
    end
    klass.new(source: source)
  end

  it "parses {X} into the mana cost" do
    expect(ability.costs.first.cost).to eq(x: 1, green: 1)
  end

  it "pays X=0" do
    p1.add_mana(green: 1)
    p1.activate_ability(ability: ability, value_for_x: 0) { |a| a.pay_mana(green: 1) }
    game.stack.resolve!

    expect(seen).to eq([0])
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "pays X=2 and hands X to the effect" do
    p1.add_mana(green: 3)
    p1.activate_ability(ability: ability, value_for_x: 2) { |a| a.pay_mana(x: { green: 2 }, green: 1) }
    game.stack.resolve!

    expect(seen).to eq([2])
    expect(p1.mana_pool.values.sum).to eq(0)
  end

  it "rejects X=2 when the pool has too little mana" do
    p1.add_mana(green: 2)
    action = p1.prepare_activate_ability(ability: ability, value_for_x: 2)

    expect(action.can_be_activated?(p1)).to eq(false)
    expect { p1.activate_ability(ability: ability, value_for_x: 2) { |a| a.pay_mana(x: { green: 1 }, green: 1) } }
      .to raise_error(Magic::Costs::Mana::CannotPay)
    expect(seen).to be_empty
  end

  it "can be activated with a larger X only when the mana is there" do
    p1.add_mana(green: 3)

    expect(p1.prepare_activate_ability(ability: ability, value_for_x: 2).can_be_activated?(p1)).to eq(true)
    expect(p1.prepare_activate_ability(ability: ability, value_for_x: 3).can_be_activated?(p1)).to eq(false)
  end
end
