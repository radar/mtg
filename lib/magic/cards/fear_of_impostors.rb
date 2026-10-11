module Magic
  module Cards
    FearOfImpostors = Creature("Fear of Impostors") do
      enchantment_creature_type("Nightmare")
      cost generic: 1, blue: 2
      keywords :flash
      power 3
      toughness 2
    end

    class FearOfImpostors < Creature
      class CounterChoice < Magic::Choice::Targeted
        def prompt = "Counter target spell. Its controller manifests dread."

        def choices = game.stack.spells

        def choice_amount = 1

        def resolve!(target:)
          caster = target.player
          trigger_effect(:counter_spell, target: target)
          Magic::Choice::ManifestDread.perform(actor: actor, player: caster)
        end
      end

      # "When this creature enters, counter target spell. Its controller manifests dread."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          choice = CounterChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
