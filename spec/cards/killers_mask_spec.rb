# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::KillersMask do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:mask) do
    ResolvePermanent("Killers Mask", owner: p1).tap do
      game.settle!
      game.resolve_choice!(target: game.choices.last.choices.first)
      game.settle!
    end
  end

  let(:manifested) { p1.permanents.find(&:face_down?) }

  it "manifests dread when it enters, then attaches to that creature" do
    expect(mask.attached_to).to eq(manifested)
  end

  it "gives the equipped creature menace" do
    game.tick!

    expect(manifested).to have_keyword(:menace)
  end

  it "can equip another creature for {2}" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(black: 2)
    p1.activate_ability(ability: mask.activated_abilities.first) do |action|
      action.pay_mana(generic: { black: 2 })
      action.targeting(bears)
    end
    game.stack.resolve!
    game.settle!

    expect(bears).to have_keyword(:menace)
    expect(manifested).not_to have_keyword(:menace)
  end
end
