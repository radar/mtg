module Magic
  module Cards
    HarshMentor = Creature("Harsh Mentor") do
      cost generic: 1, red: 1
      creature_type "Human Cleric"
      power 2
      toughness 2
    end

    class HarshMentor < Creature
      # "Whenever an opponent activates an ability of an artifact, creature, or land on the battlefield, if it isn't a mana
      # ability, this creature deals 2 damage to that player."
      class AbilityTrigger < TriggeredAbility
        def should_perform?
          return false unless opponents.include?(event.player)
          return false if event.ability.is_a?(Magic::ManaAbility)

          source = event.ability.source
          source.is_a?(Permanent) && source.zone&.battlefield? && (source.artifact? || source.creature? || source.land?)
        end

        def call
          deal_damage 2, to: event.player
        end
      end

      def event_handlers = { Events::AbilityActivated => AbilityTrigger }
    end
  end
end
