module Magic
  module Cards
    SteampathCharger = Creature("Steampath Charger") do
      cost generic: 1, red: 1
      creature_type("Lizard Warlock")
      power 2
      toughness 1
      offspring generic: 2
    end

    class SteampathCharger < Creature
      # When this creature dies, it deals 1 damage to target player.
      class DiesTrigger < TriggeredAbility::Death
        class DamageChoice < Magic::Choice::Targeted
          def choices = game.players

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:deal_damage, target: target, damage: 1)
          end
        end

        def call
          game.add_choice(DamageChoice.new(actor: actor))
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
