module Magic
  module Cards
    ImskirIronEater = Creature("Imskir Iron-Eater") do
      cost "{6}{B}{R}"
      legendary_creature_type "Demon"
      power 5
      toughness 5
    end

    class ImskirIronEater < Creature
      # "Affinity for artifacts": costs {1} less for each artifact you control.
      def self_mana_cost_adjustment
        buyer = controller || owner
        { generic: -> { -buyer.permanents.artifacts.count } }
      end

      # "When Imskir enters, you draw X cards and you lose X life, where X is half the number of artifacts you control,
      # rounded down."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          x = controller.permanents.artifacts.count / 2
          return if x.zero?

          draw_cards(x)
          lose_life(controller, x)
        end
      end

      # "{3}{R}, Sacrifice an artifact: Imskir deals damage equal to the sacrificed artifact's mana value to any target."
      class DamageAbility < Magic::ActivatedAbility
        def costs
          [Costs::Mana.new("{3}{R}"), Costs::Sacrifice.new(source, controller.permanents.artifacts)]
        end

        def target_choices = game.any_target

        def resolve!(target:, sacrificed:)
          deal_damage(sacrificed.sum(&:mana_value), to: target)
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [DamageAbility]
    end
  end
end
