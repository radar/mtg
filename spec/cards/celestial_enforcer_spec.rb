require 'spec_helper'

RSpec.describe Magic::Cards::CelestialEnforcer do
  include_context "two player game"

  let(:permanent) { ResolvePermanent("Celestial Enforcer", owner: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", owner: p1) }

  context "activated ability" do
    def ability
      permanent.activated_abilities.first
    end

    context "when p1 has two white mana" do
      before do
        p1.add_mana(white: 2)
      end

      context "when celestial enforcer is untapped" do
        context "and p1 controls a creature with flying" do
          before do
            ResolvePermanent("Aven Gagglemaster", owner: p1)
          end

          it "taps a target creature" do
            p1.add_mana(white: 2)
            p1.activate_ability(ability: ability) do
              _1
                .targeting(wood_elves)
                .pay_mana(generic: { white: 1 }, white: 1)
                .pay_tap
            end
            game.stack.resolve!
            expect(permanent).to be_tapped
            expect(wood_elves).to be_tapped
          end
        end

        context "when p1 does not control any creatures with flying" do
          it "cannot be activated" do
            action = p1.prepare_activate_ability(ability: ability)
            expect(action.can_be_activated?(p1)).to eq(false)
          end
        end
      end

      context "when celestial enforcer is tapped" do
        before { permanent.tap! }

        it "cannot be activated" do
          action = p1.prepare_activate_ability(ability: ability)
          expect(action.can_be_activated?(p1)).to eq(false)
        end
      end
    end
  end
end
