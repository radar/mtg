# frozen_string_literal: true

require "spec_helper"

RSpec.describe Magic::Cards::StayHiddenStaySilent do
  include_context "two player game"

  before { go_to_main_phase! }

  let(:card) { Card("Stay Hidden Stay Silent", owner: p1) }
  let!(:theirs) { ResolvePermanent("Grizzly Bears", owner: p2) }

  def enchant(target)
    p1.add_mana(blue: 2)
    p1.cast(card: card) do
      _1.pay_mana(generic: { blue: 1 }, blue: 1)
      _1.targeting(target)
    end
    game.stack.resolve!
    game.settle!
  end

  let(:aura) { p1.permanents.find { _1.name == "Stay Hidden, Stay Silent" } }

  it "taps the enchanted creature when it enters" do
    enchant(theirs)

    expect(theirs).to be_tapped
  end

  it "keeps the creature from untapping during its controller's untap step" do
    enchant(theirs)
    current_turn.end!
    current_turn.cleanup!
    game.next_turn
    current_turn.untap!

    expect(theirs).to be_tapped
  end

  describe "the shuffle ability" do
    before { enchant(theirs) }

    def activate!
      p1.add_mana(blue: 6)
      p1.activate_ability(ability: aura.activated_abilities.first) { _1.pay_mana(generic: { blue: 4 }, blue: 2) }
      game.stack.resolve!
      game.settle!
    end

    it "shuffles the enchanted creature into its owner's library, then you manifest dread" do
      activate!

      expect(theirs.zone).to be_nil
      expect(p2.library.cards.map(&:name)).to include("Grizzly Bears")
      choice = game.choices.last
      expect(choice).to be_a(Magic::Choice::ManifestDread)
      expect(choice.player).to eq(p1)
      game.resolve_choice!(target: choice.choices.first)
      expect(p1.permanents.count(&:face_down?)).to eq(1)
    end

    it "only works at sorcery speed" do
      game.next_turn
      go_to_main_phase!
      p1.add_mana(blue: 6)

      expect { p1.activate_ability(ability: aura.activated_abilities.first) { _1.pay_mana(generic: { blue: 4 }, blue: 2) } }.to raise_error(StandardError)
    end
  end
end
