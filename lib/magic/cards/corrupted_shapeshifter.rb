module Magic
  module Cards
    CorruptedShapeshifter = Creature("Corrupted Shapeshifter") do
      cost generic: 3, blue: 1
      creature_type "Eldrazi Shapeshifter"
      power 0
      toughness 0
      keywords :devoid
      enters_as_copy # holds off the 0/0 state-based action until the form is chosen
    end

    class CorruptedShapeshifter < Creature
      # "As this creature enters, it becomes your choice of a 3/3 creature with flying, a 2/5 creature with
      # vigilance, or a 0/12 creature with defender." Declining takes the first form.
      class FormChoice < Magic::Choice
        FORMS = {
          flier: { power: 3, toughness: 3, keyword: Keywords::FLYING },
          vigilant: { power: 2, toughness: 5, keyword: Keywords::VIGILANCE },
          wall: { power: 0, toughness: 12, keyword: Keywords::DEFENDER },
        }.freeze

        def choices = FORMS.keys

        def resolve!(form:)
          raise ArgumentError, "Invalid form #{form.inspect}" unless FORMS.key?(form)

          stats = FORMS.fetch(form)
          actor.modify_base_power(stats[:power], until_eot: false)
          actor.modify_base_toughness(stats[:toughness], until_eot: false)
          actor.grant_keyword(stats[:keyword], until_eot: false)
          actor.copy_choice_pending = false
        end

        def decline!
          resolve!(form: choices.first)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(FormChoice.new(actor:))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
