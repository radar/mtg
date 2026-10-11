# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::HauntwoodsShrieker do
  include_context "two player game"

  let!(:shrieker) { ResolvePermanent("Hauntwoods Shrieker", owner: p1) }

  def manifest(owner, name)
    card = Card(name, owner: owner).tap { owner.library.add(_1) }
    game.manifest!(card, controller: owner).tap { game.settle! }
  end

  it "is a 3/3 Beast Mutant" do
    expect([shrieker.power, shrieker.toughness]).to eq([3, 3])
  end

  it "manifests dread whenever it attacks" do
    skip_to_combat!
    current_turn.declare_attackers!
    p1.declare_attacker(attacker: shrieker, target: p2)
    current_turn.attackers_declared!
    game.settle!
    game.resolve_choice!(target: game.choices.last.choices.first)

    expect(p1.permanents.count(&:face_down?)).to eq(1)
  end

  describe "the reveal ability" do
    before { go_to_main_phase! }

    def reveal(target)
      p1.add_mana(green: 2)
      p1.activate_ability(ability: shrieker.activated_abilities.first) do |action|
        action.pay_mana(generic: { green: 1 }, green: 1)
        action.targeting(target)
      end
      game.stack.resolve!
      game.settle!
    end

    it "reveals a face-down creature card and lets you turn it face up for free" do
      manifested = manifest(p1, "Grizzly Bears")
      reveal(manifested)
      expect(game.choices.last).to be_a(described_class::TurnFaceUpChoice)
      game.resolve_choice!

      expect(manifested).not_to be_face_down
      expect(manifested.name).to eq("Grizzly Bears")
    end

    it "lets you leave it face down" do
      manifested = manifest(p1, "Grizzly Bears")
      reveal(manifested)
      game.skip_choice!

      expect(manifested).to be_face_down
    end

    it "offers nothing for a face-down card that isn't a creature card" do
      manifested = manifest(p1, "Island")
      reveal(manifested)

      expect(game.choices).to be_empty
      expect(manifested).to be_face_down
    end

    it "can target an opponent's face-down permanent" do
      theirs = manifest(p2, "Grizzly Bears")
      reveal(theirs)

      expect(game.choices.last).to be_a(described_class::TurnFaceUpChoice)
    end
  end
end
