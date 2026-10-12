module Magic
  module Cards
    InfernalPhantom = Creature("Infernal Phantom") do
      cost generic: 3, red: 1
      creature_type "Spirit"
      power 2
      toughness 3
    end

    class InfernalPhantom < Creature
      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, this creature gets
      # +2/+0 until end of turn."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 2, toughness: 0, until_eot: true)
        end
      end

      # "When this creature dies, it deals damage equal to its power to any target."
      class DiesTrigger < TriggeredAbility::Death
        class DamageChoice < Magic::Choice::Targeted
          def initialize(actor:, damage:)
            super(actor: actor)
            @damage = damage
          end

          def choices = game.any_target

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:deal_damage, damage: @damage, target: target)
          end
        end

        def call
          game.add_choice(DamageChoice.new(actor: actor, damage: actor.power))
        end
      end

      def event_handlers = EerieTrigger.handlers
      def death_triggers = [DiesTrigger]
    end
  end
end
