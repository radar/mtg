# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::DistinguishedConjurer do
  include_context "two player game"

  let!(:conjurer) { ResolvePermanent("Distinguished Conjurer", owner: p1) }

  before { go_to_main_phase! }

  it "is a 1/2 Human Wizard" do
    expect([conjurer.power, conjurer.toughness]).to eq([1, 2])
  end

  context "whenever another creature you control enters" do
    it "gains 1 life" do
      expect { ResolvePermanent("Grizzly Bears", owner: p1) }.to change { p1.life }.by(1)
    end

    it "does not trigger for an opponent's creature" do
      expect { ResolvePermanent("Grizzly Bears", owner: p2) }.not_to change { p1.life }
    end

    it "does not trigger for a noncreature permanent" do
      expect { ResolvePermanent("Ruby Medallion", owner: p1) }.not_to change { p1.life }
    end

    it "gains only 1 life (not 2) when a second Conjurer enters, as each sees only the other" do
      expect { ResolvePermanent("Distinguished Conjurer", owner: p1) }.to change { p1.life }.by(1)
    end
  end

  context "{4}{W}, {T}: blink another creature you control" do
    let(:ability) { conjurer.activated_abilities.first }
    let!(:bear) { ResolvePermanent("Grizzly Bears", owner: p1) }

    def activate(target)
      p1.add_mana(white: 5)
      p1.activate_ability(ability: ability) do
        _1.pay_mana(generic: { white: 4 }, white: 1)
        _1.targeting(target)
      end
      game.stack.resolve!
      game.settle!
    end

    it "exiles and returns the creature, taps the Conjurer, and triggers the lifegain" do
      old_life = p1.life
      activate(bear)
      expect(conjurer).to be_tapped
      expect(p1.creatures.map(&:name)).to match_array(["Distinguished Conjurer", "Grizzly Bears"])
      expect(p1.creatures.find { _1.name == "Grizzly Bears" }).not_to equal(bear)
      expect(p1.life).to eq(old_life + 1)
    end

    it "cannot target the Conjurer itself" do
      expect(ability.target_choices).not_to include(conjurer)
      expect(ability.target_choices).to include(bear)
    end

    it "cannot target an opponent's creature" do
      theirs = ResolvePermanent("Grizzly Bears", owner: p2)
      expect(ability.target_choices).not_to include(theirs)
    end

    it "fails without enough mana" do
      p1.add_mana(white: 2)
      expect do
        p1.activate_ability(ability: ability) do
          _1.pay_mana(generic: { white: 1 }, white: 1)
          _1.targeting(bear)
        end
      end.to raise_error(Magic::Costs::Mana::CannotPay)
    end
  end
end
