module Magic
  module Cards
    DistinguishedConjurer = Creature("Distinguished Conjurer") do
      cost generic: 1, white: 1
      creature_type "Human Wizard"
      power 1
      toughness 2
    end

    class DistinguishedConjurer < Creature
      # Whenever another creature you control enters, you gain 1 life.
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = another_creature? && under_your_control?

        def call = gain_life(1)
      end

      # {4}{W}, {T}: Exile another target creature you control, then return it to the battlefield under its
      # owner's control.
      class BlinkAbility < Magic::ActivatedAbility
        costs "{4}{W}, {T}"

        def target_choices = battlefield.controlled_by(controller).creatures - [source]

        def resolve!(target:)
          card = target.card
          exile_target(target)
          card.resolve!(controller: card.owner) if card.zone&.exile?
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }

      def activated_abilities = [BlinkAbility]
    end
  end
end
