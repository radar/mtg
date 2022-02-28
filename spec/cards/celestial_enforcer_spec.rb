require 'spec_helper'

RSpec.describe Magic::Cards::CelestialEnforcer do
  include_context "two player game"

  subject { Card("Celestial Enforcer", controller: p1) }
  let(:wood_elves) { Card("Wood Elves") }

  before do
    game.battlefield.add(wood_elves)
  end

  context "triggered ability" do
    def ability
      subject.activated_abilities.first
    end

    context "when p1 has two white mana" do
      before do
        p1.add_mana(white: 2)
      end

      context "when celestial enforcer is untapped" do
        context "and p1 controls a creature with flying" do
          let(:aven_gagglemaster) { Card("Aven Gagglemaster", controller: p1) }
          before do
            game.battlefield.add(aven_gagglemaster)
          end

          it "taps a target creature" do
            expect(subject.activated_abilities.count).to eq(1)
            p1.add_mana(white: 5)
            activation = p1.prepare_to_activate(ability)
            activation.pay(:mana, generic: { white: 1 }, white: 1)
            activation.activate!
            expect(subject).to be_tapped
            tap_target = game.next_effect
            expect(tap_target).to be_a(Magic::Effects::TapTarget)
            expect(tap_target.choices).to include(wood_elves, aven_gagglemaster)
            game.resolve_pending_effect(wood_elves)
            expect(wood_elves).to be_tapped
          end
        end

        context "when p1 does not control any creatures with flying" do
          it "cannot be activated" do
            activation = p1.prepare_to_activate(ability)
            expect(activation.can_be_activated?(p1)).to eq(false)
          end
        end
      end

      context "when celestial enforcer is tapped" do
        before { subject.tap! }

        it "cannot be activated" do
          activation = p1.prepare_to_activate(ability)
          expect(activation.can_be_activated?(p1)).to eq(false)
        end
      end
    end
  end
end
