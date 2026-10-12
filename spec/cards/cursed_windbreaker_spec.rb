# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::CursedWindbreaker do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:windbreaker) do
    ResolvePermanent("Cursed Windbreaker", owner: p1).tap do
      game.settle!
      game.resolve_choice!(target: game.choices.last.choices.first)
      game.settle!
    end
  end

  let(:manifested) { p1.permanents.find(&:face_down?) }

  it "manifests dread when it enters, then attaches to that creature" do
    expect(windbreaker.attached_to).to eq(manifested)
  end

  it "gives the equipped creature flying" do
    game.tick!

    expect(manifested).to be_flying
  end

  it "can equip another creature for {3}, which then flies" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(blue: 3)
    p1.activate_ability(ability: windbreaker.activated_abilities.first) do |action|
      action.pay_mana(generic: { blue: 3 })
      action.targeting(bears)
    end
    game.stack.resolve!
    game.settle!

    expect(bears).to be_flying
    expect(manifested).not_to be_flying
  end
end
