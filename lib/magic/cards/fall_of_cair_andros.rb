module Magic
  module Cards
    FallOfCairAndros = Enchantment("Fall of Cair Andros") do
      cost generic: 2, red: 1
    end

    class FallOfCairAndros < Enchantment
      # "Whenever a creature an opponent controls is dealt excess noncombat damage, amass Orcs X, where X is that
      # excess damage."
      class ExcessDamageTrigger < TriggeredAbility
        def should_perform?
          !event.combat? && event.excess.positive? && event.target.is_a?(Magic::Permanent) &&
            event.target.creature? && event.target.controller != controller
        end

        def call
          Magic::Amass.call(source: actor, controller: controller, amount: event.excess, subtype: "Orc")
        end
      end

      # "{7}{R}: This enchantment deals 7 damage to target creature."
      class DamageAbility < Magic::ActivatedAbility
        costs "{7}{R}"

        def target_choices = game.battlefield.creatures

        def resolve!(target:)
          deal_damage(7, to: target)
        end
      end

      def activated_abilities = [DamageAbility]

      def event_handlers = { Events::DamageDealt => ExcessDamageTrigger }
    end
  end
end
