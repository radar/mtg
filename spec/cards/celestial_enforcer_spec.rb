require 'spec_helper'

RSpec.describe Magic::Cards::CelestialEnforcer do
  include_context "two player game"

  let(:permanent) { ResolvePermanent("Celestial Enforcer", controller: p1) }
  let!(:wood_elves) { ResolvePermanent("Wood Elves", controller: p1) }

  context "activated ability" do
    def ability
      permanent.card.class::ActivatedAbility
    end

    context "when p1 has two white mana" do
      before do
        p1.add_mana(white: 2)
      end

      context "when celestial enforcer is untapped" do
        context "and p1 controls a creature with flying" do
          before do
            ResolvePermanent("Aven Gagglemaster", controller: p1)
          end

          it "taps a target creature" do
            p1.add_mana(white: 2)
            action = Magic::Actions::ActivateAbility.new(player: p1, permanent: permanent, ability: ability)
            action.pay_mana(generic: { white: 1 }, white: 1)
            action.pay_tap
            action.targeting(wood_elves)
            game.take_action(action)
            game.stack.resolve!
            expect(permanent).to be_tapped
            expect(wood_elves).to be_tapped
          end
        end

        context "when p1 does not control any creatures with flying" do
          it "cannot be activated" do
            action = Magic::Actions::ActivateAbility.new(player: p1, permanent: permanent, ability: ability)
            expect(action.can_be_activated?(p1)).to eq(false)
          end
        end
      end

      context "when celestial enforcer is tapped" do
        before { permanent.tap! }

        it "cannot be activated" do
          action = Magic::Actions::ActivateAbility.new(player: p1, permanent: permanent, ability: ability)
          expect(action.can_be_activated?(p1)).to eq(false)
        end
      end
    end
  end
end
