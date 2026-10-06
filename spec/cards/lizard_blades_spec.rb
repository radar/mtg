# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::LizardBlades do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:blades) { ResolvePermanent("Lizard Blades", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  def reconfigure(ability_index, target: nil)
    p1.add_mana(red: 2)
    p1.activate_ability(ability: blades.activated_abilities[ability_index]) do |a|
      a.pay_mana(generic: { red: 2 })
      a.targeting(target) if target
    end
    game.stack.resolve!
    game.tick!
  end

  it "is a 1/1 double-strike artifact creature Equipment Lizard" do
    expect([blades.power, blades.toughness]).to eq([1, 1])
    expect(blades).to have_keyword(:double_strike)
    expect(blades).to be_creature
    expect(blades.type?("Equipment")).to be true
    expect(blades.type?("Lizard")).to be true
  end

  it "reconfigures onto a creature you control, giving it double strike" do
    reconfigure(0, target: bears)

    expect(blades.attached_to).to eq(bears)
    expect(bears).to have_keyword(:double_strike)
  end

  it "isn't a creature while attached" do
    reconfigure(0, target: bears)

    expect(blades).not_to be_creature
    expect(p1.creatures).not_to include(blades)
    expect(blades.type?("Equipment")).to be true
  end

  it "unattaches, becoming a creature again and no longer granting double strike" do
    reconfigure(0, target: bears)
    reconfigure(1)

    expect(blades.attached_to).to be_nil
    expect(blades).to be_creature
    expect(bears).not_to have_keyword(:double_strike)
  end

  it "can only be reconfigured as a sorcery" do
    current_turn.end!
    p1.add_mana(red: 2)

    expect do
      p1.activate_ability(ability: blades.activated_abilities[0]) { |a| a.pay_mana(generic: { red: 2 }).targeting(bears) }
    end.to raise_error(Magic::IllegalAction)
  end

  it "can't attach to itself or an opponent's creature" do
    theirs = ResolvePermanent("Grizzly Bears", owner: p2)
    choices = blades.activated_abilities[0].target_choices

    expect(choices).to include(bears)
    expect(choices).not_to include(blades, theirs)
  end
end
