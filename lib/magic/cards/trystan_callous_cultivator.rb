module Magic
  module Cards
    # Trystan, Penitent Culler (back face). Its mana value is the front face's, and its colour
    # comes from a colour indicator.
    class TrystanPenitentCuller < Creature
      card_name "Trystan, Penitent Culler"
      legendary_creature_type "Elf Warlock"
      color_indicator :black
      power 3
      toughness 4
      keywords :deathtouch

      class ExileElfChoice < Magic::Choice::May
        def choices = controller.graveyard.cards.select { _1.type?("Elf") }

        def target_choices = Magic::Targets::Choices.new(choices:, amount: 1)

        def single_target? = true

        # "... you may exile an Elf card from your graveyard. If you do, each opponent loses 2 life."
        def resolve!(target:)
          raise ArgumentError, "#{target.name} isn't an Elf card in your graveyard" unless choices.include?(target)

          trigger_effect(:exile, target:)
          game.opponents(controller).each { trigger_effect(:lose_life, target: _1, life: 2) }
        end
      end

      # "Whenever this creature transforms into Trystan, Penitent Culler, mill three cards, then you
      # may exile an Elf card from your graveyard. If you do, each opponent loses 2 life."
      class TransformedTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor

        def call
          controller.mill(3)
          choice = ExileElfChoice.new(actor:)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay green: 1
      end

      def event_handlers
        { Events::PermanentTransformed => TransformedTrigger, Events::FirstMainPhase => PayToTransformTrigger }
      end
    end

    class TrystanCallousCultivator < Creature
      card_name "Trystan, Callous Cultivator"
      cost generic: 2, green: 1
      legendary_creature_type "Elf Druid"
      power 3
      toughness 4
      keywords :deathtouch
      back_face TrystanPenitentCuller

      # "Whenever this creature enters or transforms into Trystan, Callous Cultivator, mill three
      # cards. Then if there is an Elf card in your graveyard, you gain 2 life."
      class MillTrigger < TriggeredAbility
        def should_perform? = event.permanent == actor

        def call
          controller.mill(3)
          trigger_effect(:gain_life, target: controller, life: 2) if controller.graveyard.cards.any? { _1.type?("Elf") }
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call = MillTrigger.new(event:, actor:).call
      end

      class PayToTransformTrigger < TriggeredAbility::PayToTransform
        pay black: 1
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::PermanentTransformed => MillTrigger, Events::FirstMainPhase => PayToTransformTrigger }
      end
    end
  end
end
