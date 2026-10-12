module Magic
  module Cards
    class UnholyAnnexRitualChamber < Room
      DemonToken = Token.create "Demon" do
        creature_type "Demon"
        colors :black
        keywords :flying
        power 6
        toughness 6
      end

      class UnholyAnnex < Room::Door
        card_name "Unholy Annex"
        cost generic: 2, black: 1

        # "At the beginning of your end step, draw a card. If you control a Demon, each opponent loses 2 life and you gain 2
        # life. Otherwise, you lose 2 life."
        class EndStepTrigger < TriggeredAbility
          def should_perform? = event.active_player == controller

          def call
            trigger_effect(:draw_card)
            if controller.creatures.any? { _1.type?("Demon") }
              opponents.each { trigger_effect(:lose_life, target: _1, life: 2) }
              gain_life(2)
            else
              trigger_effect(:lose_life, target: controller, life: 2)
            end
          end
        end

        def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
      end

      class RitualChamber < Room::Door
        card_name "Ritual Chamber"
        cost generic: 3, black: 2

        # "When you unlock this door, create a 6/6 black Demon creature token with flying."
        when_unlocked do
          trigger_effect(:create_token, token_class: UnholyAnnexRitualChamber::DemonToken)
        end
      end

      doors UnholyAnnex, RitualChamber
    end
  end
end
