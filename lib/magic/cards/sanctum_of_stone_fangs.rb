module Magic
  module Cards
    SanctumOfStoneFangs = Enchantment("Sanctum of Stone Fangs") do
      type T::Super::Legendary, T::Enchantment, "Shrine"
      cost generic: 1, black: 1
    end

    class SanctumOfStoneFangs < Enchantment
      # "At the beginning of your first main phase, each opponent loses X life and you gain X life, where X is the
      # number of Shrines you control."
      class FirstMainPhaseTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          shrines = controller.permanents.by_type("Shrine").count
          opponents.each { |opponent| trigger_effect(:lose_life, target: opponent, life: shrines) }
          trigger_effect(:gain_life, life: shrines)
        end
      end

      def event_handlers = { Events::FirstMainPhase => FirstMainPhaseTrigger }
    end
  end
end
