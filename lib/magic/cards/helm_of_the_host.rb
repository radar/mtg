module Magic
  module Cards
    HelmOfTheHost = Equipment("Helm of the Host") do
      type T::Super::Legendary, T::Artifact, "Equipment"
      cost generic: 4
      equip [Costs::Mana.new(generic: 5)]
    end

    class HelmOfTheHost < Equipment
      # "At the beginning of combat on your turn, create a token that's a copy of equipped creature, except the token
      # isn't legendary. That token gains haste."
      class CombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.attached_to&.creature?
        end

        def call
          copy = Permanent.resolve(
            game: game,
            owner: controller,
            card: actor.attached_to.copiable_card,
            token: true,
            copy: true,
            cast: false,
          )
          copy.remove_types(T::Super::Legendary, until_eot: false)
          copy.grant_keyword(Keywords::HASTE, until_eot: false)
          copy.apply_continuous_effects!
        end
      end

      def event_handlers = { Events::BeginningOfCombat => CombatTrigger }
    end
  end
end
