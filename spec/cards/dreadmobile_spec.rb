# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::Dreadmobile do
  include_context "two player game"
  before { go_to_main_phase! }

  let!(:vehicle) { ResolvePermanent("Dreadmobile", owner: p1) }
  let!(:bears) { ResolvePermanent("Grizzly Bears", owner: p1) }

  it "is a 3/3 Vehicle with menace" do
    expect(vehicle).to be_artifact
    expect(vehicle).not_to be_creature
    expect(vehicle.base_power).to eq(3)
    expect(vehicle.keywords).to include(Magic::Cards::Keywords::MENACE)
  end

  it "can be crewed with crew 1" do
    p1.activate_ability(ability: vehicle.activated_abilities.first) { |a| a.pay_multi_tap([bears]) }
    game.stack.resolve!
    game.tick!

    expect(vehicle).to be_creature
  end

  describe "{1}, Sacrifice another artifact or creature" do
    def grow!(sacrifice)
      p1.add_mana(black: 1)
      p1.activate_ability(ability: vehicle.activated_abilities.last) do |a|
        a.pay_mana(generic: { black: 1 })
        a.pay_sacrifice(sacrifice)
      end
      game.stack.resolve!
      game.tick!
    end

    it "sacrifices a creature to put a +1/+1 counter on the Vehicle" do
      grow!(bears)

      expect(p1.graveyard.cards.map(&:name)).to include("Grizzly Bears")
      expect(vehicle.counters.size).to eq(1)
    end

    it "sacrifices an artifact" do
      ram = ResolvePermanent("Cranial Ram", owner: p1)
      grow!(ram)

      expect(p1.graveyard.cards.map(&:name)).to include("Cranial Ram")
      expect(vehicle.counters.size).to eq(1)
    end

    it "can't sacrifice itself" do
      expect { grow!(vehicle) }.to raise_error(Magic::Costs::SacrificeAnother::SourceSacrificed)
    end
  end
end
