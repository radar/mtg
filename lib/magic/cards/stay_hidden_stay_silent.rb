module Magic
  module Cards
    StayHiddenStaySilent = Aura("Stay Hidden, Stay Silent") do
      cost generic: 1, blue: 1
    end

    class StayHiddenStaySilent < Aura
      enchant "Creature"

      def target_choices = battlefield.creatures

      # "Enchanted creature doesn't untap during its controller's untap step."
      def does_not_untap_during_untap_step? = true

      # "When this Aura enters, tap enchanted creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          creature = actor.attached_to
          tap_permanent(creature) if creature
        end
      end

      # "{4}{U}{U}: Shuffle enchanted creature into its owner's library, then manifest dread. Activate only as a sorcery."
      class ShuffleAbility < Magic::ActivatedAbility
        costs "{4}{U}{U}"

        def requirements_met?
          game.can_cast_sorcery?(controller) && !source.attached_to.nil?
        end

        def resolve!
          creature = source.attached_to
          return unless creature

          game.add_effect(Effects::ShuffleIntoLibrary.new(source: source, target: creature))
          Magic::Choice::ManifestDread.perform(actor: source)
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [ShuffleAbility]
    end
  end
end
