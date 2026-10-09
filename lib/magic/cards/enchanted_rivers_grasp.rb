module Magic
  module Cards
    EnchantedRiversGrasp = Aura("Enchanted River's Grasp") do
      cost generic: 2, blue: 1
    end

    class EnchantedRiversGrasp < Aura
      enchant "Creature"

      def target_choices = battlefield.creatures

      def does_not_untap_during_untap_step? = true

      # "Enchanted creature loses all abilities and doesn't untap during its controller's untap step."
      class LoseAbilities < Abilities::Static::CharacteristicSetting
        applies_to_target
        loses_all_abilities
      end

      def static_abilities = [LoseAbilities]

      # "When this Aura enters, tap enchanted creature and remove all counters from it."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          creature = actor.attached_to
          return unless creature

          trigger_effect(:tap, target: creature)
          creature.counters.map(&:class).tally.each do |counter_class, amount|
            creature.remove_counter(counter_type: counter_class, amount: amount)
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
