module Magic
  module Cards
    KindleTheInnerFlame = Sorcery("Kindle the Inner Flame") do
      cost generic: 3, red: 1
      type T::Kindred, T::Sorcery, T::Creatures["Elemental"]
      flashback Costs::Mana.new(generic: 1, red: 1)
    end

    class KindleTheInnerFlame < Sorcery
      class EndStepSacrifice < TriggeredAbility
        def call
          actor.sacrifice!
        end
      end

      def target_choices
        battlefield.creatures.controlled_by(controller)
      end

      def resolve!(target:)
        copy = Permanent.resolve(
          game: game,
          owner: controller,
          card: target.copiable_card,
          token: true,
          copy: true,
          cast: false,
        )
        copy.grant_haste!
        copy.register_turn_trigger(Events::BeginningOfEndStep, EndStepSacrifice)
      end

      # Behold three Elementals: choose Elementals you control or reveal Elemental cards
      # from your hand. Beholding doesn't move or tap anything, so it's only a requirement.
      def flashback_requirements_met?(player)
        beholdable = player.creatures.count { |creature| creature.type?("Elemental") } +
          player.hand.cards.count { |card| card.type?("Elemental") }
        beholdable >= 3
      end
    end
  end
end
