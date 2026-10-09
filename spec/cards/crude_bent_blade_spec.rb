# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CrudeBentBlade do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "makes the opponent sacrifice a creature of their choice when it enters" do
    victim = ResolvePermanent("Grizzly Bears", owner: p2)
    other = ResolvePermanent("Wood Elves", owner: p2)
    ResolvePermanent("Crude Bent Blade", owner: p1)
    game.settle!
    game.resolve_choice!(target: victim)
    game.settle!

    expect(victim.zone).to be_nil
    expect(other.zone).to be_battlefield
    expect(bears.zone).to be_battlefield
  end

  it "gives equipped creature +2/+1 once equipped" do
    blade = ResolvePermanent("Crude Bent Blade", owner: p1)
    game.settle!
    p1.add_mana(green: 2)
    p1.activate_ability(ability: blade.activated_abilities.first) do
      _1.targeting(bears)
      _1.pay_mana(generic: { green: 2 })
    end
    game.stack.resolve!
    game.tick!

    expect(blade.attached_to).to eq(bears)
    expect([bears.power, bears.toughness]).to eq([4, 3])
  end
end
