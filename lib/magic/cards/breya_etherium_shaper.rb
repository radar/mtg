module Magic
  module Cards
    BreyaEtheriumShaper = Creature("Breya, Etherium Shaper") do
      cost "{W}{U}{B}{R}"
      type T::Super::Legendary, T::Artifact, T::Creature, T::Creatures["Human"]
      power 4
      toughness 4
    end

    class BreyaEtheriumShaper < Creature
      ThopterToken = Token.create("Thopter") do
        artifact_creature_type "Thopter"
        power 1
        toughness 1
        colors :blue
        keywords :flying
      end

      # "When Breya enters, create two 1/1 blue Thopter artifact creature tokens with flying."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          2.times { create_token(token: ThopterToken) }
        end
      end

      class SacrificeTwoArtifacts < Costs::Sacrifice
        def can_pay?(_player = nil) = choices.size >= 2

        def pay(payment:)
          payment = Array(payment)
          unless payment.uniq.size == 2 && payment.all? { choices.include?(_1) }
            raise "Sacrifice exactly two of: #{choices.map(&:name).join(', ')}"
          end

          payment.each(&:sacrifice!)
        end
      end

      # "{2}, Sacrifice two artifacts: Choose one --" Each mode is its own activated ability sharing the same costs, so
      # the mode (and its targets) is picked by choosing which ability to activate.
      class ModeAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 2),
            SacrificeTwoArtifacts.new(source, source.controller.permanents.select(&:artifact?))
          ]
        end
      end

      class DamageMode < ModeAbility
        def description = "Breya deals 3 damage to target player or planeswalker"

        def target_choices = game.players + game.battlefield.planeswalkers

        def resolve!(target:)
          deal_damage(3, to: target)
        end
      end

      class ShrinkMode < ModeAbility
        def description = "Target creature gets -4/-4 until end of turn"

        def target_choices = game.battlefield.creatures

        def resolve!(target:)
          pump(target, -4, -4)
        end
      end

      class LifeMode < ModeAbility
        def description = "You gain 5 life"

        def resolve!
          gain_life 5
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [DamageMode, ShrinkMode, LifeMode]
    end
  end
end
