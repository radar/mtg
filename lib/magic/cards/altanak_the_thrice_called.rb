module Magic
  module Cards
    AltanakTheThriceCalled = Creature("Altanak, the Thrice-Called") do
      cost generic: 5, green: 2
      legendary_creature_type "Insect Beast"
      keywords :trample
      power 9
      toughness 9
    end

    class AltanakTheThriceCalled < Creature
      # "Whenever Altanak becomes the target of a spell or ability an opponent controls, draw a card."
      class TargetedBySpellTrigger < TriggeredAbility::SpellCast
        def should_perform?
          opponents.include?(event.player) && event.targets.include?(actor)
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      class TargetedByAbilityTrigger < TriggeredAbility
        def should_perform?
          opponents.include?(event.player) && event.targets.include?(actor)
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers
        super.merge({
          Events::SpellCast => TargetedBySpellTrigger,
          Events::AbilityActivated => TargetedByAbilityTrigger,
        }) { |_, old, new| [*old, *new] }
      end

      # "{1}{G}, Discard this card: Return target land card from your graveyard to the battlefield tapped."
      class ReturnLandAbility < Magic::ActivatedAbility
        def description = "Return target land card from your graveyard to the battlefield tapped"

        def costs = [Costs::Mana.new(generic: 1, green: 1), Costs::SelfDiscard.new(source)]

        def requirements_met?
          !!source.zone&.hand? && source.owner == controller
        end

        def target_choices = controller.graveyard.cards.lands

        def resolve!(target:)
          target.resolve!(enters_tapped: true)
        end
      end

      def hand_abilities = [ReturnLandAbility.new(source: self)]
    end
  end
end
