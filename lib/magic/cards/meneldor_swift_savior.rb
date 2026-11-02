module Magic
  module Cards
    MeneldorSwiftSavior = Creature("Meneldor, Swift Savior") do
      cost generic: 3, blue: 1
      legendary_creature_type("Bird Soldier")
      keywords :flying
      power 3
      toughness 3
    end

    class MeneldorSwiftSavior < Creature
      # "Exile up to one target creature you own, then return it to the battlefield under your control."
      class FlickerChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures.select { _1.owner == controller }

        def choice_amount = 0..1

        def resolve!(target:)
          return unless target

          card = target.card
          owner = target.owner
          target.exile!
          # An exiled token ceases to exist.
          return if target.token?

          Permanent.put_onto_battlefield(game: game, card: card, owner: owner, controller: controller)
        end

        def decline! = nil
      end

      # "Whenever Meneldor deals combat damage to a player, ..."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.player?
        end

        def call
          choice = FlickerChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::CombatDamageDealt => CombatDamageTrigger }
    end
  end
end
