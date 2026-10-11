# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::ConductiveMachete do
  include_context "two player game"

  before { go_to_main_phase! }

  def enter!
    machete = ResolvePermanent("Conductive Machete", owner: p1)
    game.settle!
    game.resolve_choice!(target: game.choices.last.choices.first)
    game.settle!
    machete
  end

  it "manifests dread when it enters, then attaches to that creature" do
    machete = enter!
    manifested = p1.permanents.find(&:face_down?)

    expect(machete.attached_to).to eq(manifested)
    expect(manifested.attachments).to include(machete)
  end

  it "gives the equipped creature +2/+1" do
    enter!
    manifested = p1.permanents.find(&:face_down?)

    expect([manifested.power, manifested.toughness]).to eq([4, 3])
  end

  it "can equip another creature for {4}" do
    machete = enter!
    bears = ResolvePermanent("Grizzly Bears", owner: p1)
    p1.add_mana(green: 4)
    p1.activate_ability(ability: machete.activated_abilities.first) do |action|
      action.pay_mana(generic: { green: 4 })
      action.targeting(bears)
    end
    game.stack.resolve!
    game.settle!

    expect(machete.attached_to).to eq(bears)
    expect([bears.power, bears.toughness]).to eq([4, 3])
  end

  it "stays unattached when the library is empty" do
    p1.library.cards.to_a.dup.each { p1.library.remove(_1) }
    machete = ResolvePermanent("Conductive Machete", owner: p1)
    game.settle!

    expect(machete.attached_to).to be_nil
    expect(p1.permanents.count(&:face_down?)).to eq(0)
  end
end
