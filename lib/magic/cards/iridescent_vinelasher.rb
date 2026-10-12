module Magic
  module Cards
    IridescentVinelasher = Creature("Iridescent Vinelasher") do
      cost black: 1
      creature_type("Lizard Assassin")
      power 1
      toughness 2
      offspring black: 1
    end

    class IridescentVinelasher < Creature
      # Landfall -- Whenever a land you control enters, this creature deals 1 damage to target opponent.
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform? = you?

        def call
          opponents.each { |opponent| trigger_effect(:deal_damage, target: opponent, damage: 1) }
        end
      end

      def event_handlers = super.merge(Events::Landfall => LandfallTrigger)
    end
  end
end
