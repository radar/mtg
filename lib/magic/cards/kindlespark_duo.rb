module Magic
  module Cards
    KindlesparkDuo = Creature("Kindlespark Duo") do
      cost generic: 2, red: 1
      creature_type("Lizard Otter")
      power 1
      toughness 3
    end

    class KindlesparkDuo < Creature
      # {T}: This creature deals 1 damage to target opponent.
      class PingAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          opponents.each { |opponent| deal_damage(1, to: opponent) }
        end

        def opponents = game.opponents(controller)
      end

      def activated_abilities = [PingAbility]

      # Whenever you cast a noncreature spell, untap this creature.
      class UntapTrigger < TriggeredAbility::SpellCast
        def should_perform? = event.player == controller && !spell.creature?

        def call
          actor.untap!
        end
      end

      def event_handlers = super.merge(Events::SpellCast => UntapTrigger)
    end
  end
end
