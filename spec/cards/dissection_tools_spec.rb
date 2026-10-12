# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DissectionTools do
  include_context "two player game"

  before { go_to_main_phase! }

  let!(:tools) do
    ResolvePermanent("Dissection Tools", owner: p1).tap do
      game.settle!
      game.resolve_choice!(target: game.choices.last.choices.first)
      game.settle!
    end
  end

  let(:manifested) { p1.permanents.find(&:face_down?) }

  it "manifests dread when it enters, then attaches to that creature" do
    expect(tools.attached_to).to eq(manifested)
  end

  it "gives the equipped creature +2/+2, deathtouch and lifelink" do
    game.tick!

    expect([manifested.power, manifested.toughness]).to eq([4, 4])
    expect(manifested).to have_keyword(:deathtouch)
    expect(manifested).to have_keyword(:lifelink)
  end

  it "equips by sacrificing a creature" do
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    fodder = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.activate_ability(ability: tools.activated_abilities.first) do |action|
      action.pay_sacrifice(fodder)
      action.targeting(bears)
    end
    game.stack.resolve!
    game.settle!

    expect(fodder.zone).to be_nil
    expect(tools.attached_to).to eq(bears)
    expect([bears.power, bears.toughness]).to eq([4, 4])
  end
end
