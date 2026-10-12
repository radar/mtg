module Magic
  module Cards
    SubiraTulzidiCaravanner = Creature("Subira, Tulzidi Caravanner") do
      cost generic: 2, red: 1
      legendary_creature_type "Human Shaman"
      keywords :haste
      power 2
      toughness 3
    end

    class SubiraTulzidiCaravanner < Creature
      # "{1}: Another target creature with power 2 or less can't be blocked this turn."
      class UnblockableAbility < Magic::ActivatedAbility
        costs "{1}"

        def target_choices
          battlefield.creatures.select { |creature| creature != source && creature.power <= 2 }
        end

        def resolve!(target:)
          target.grant_keyword(Keywords::CANT_BE_BLOCKED)
        end
      end

      # "{1}{R}, {T}, Discard your hand: Until end of turn, whenever a creature you control with
      # power 2 or less deals combat damage to a player, draw a card."
      class DrawAbility < Magic::ActivatedAbility
        costs "{1}{R}, {T}, Discard your hand"

        class DamageTrigger < TriggeredAbility
          def should_perform?
            event.source.controller == controller && event.source.creature? &&
              event.source.power <= 2 && event.target.is_a?(Magic::Player)
          end

          def call
            trigger_effect(:draw_card)
          end
        end

        def resolve!
          source.register_turn_trigger(Events::CombatDamageDealt, DamageTrigger)
        end
      end

      def activated_abilities = [UnblockableAbility, DrawAbility]
    end
  end
end
