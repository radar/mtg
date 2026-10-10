module Magic
  module Cards
    SpineseekerCentipede = Creature("Spineseeker Centipede") do
      cost generic: 2, green: 1
      creature_type "Insect"
      power 2
      toughness 1
    end

    class SpineseekerCentipede < Creature
      class BasicLandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :hand, reveal: true, filter: Filter[:basic_lands])
        end
      end

      # "When this creature enters, search your library for a basic land card, reveal it, put it into your hand,
      # then shuffle."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(BasicLandChoice.new(actor: actor))
        end
      end

      # "Delirium — This creature gets +1/+2 as long as there are four or more card types among cards in your
      # graveyard."
      class DeliriumBoost < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 2

        conditions { source.controller.graveyard.delirium? }
        applicable_targets { [source] }
      end

      # "... and has vigilance as long as there are four or more card types among cards in your graveyard."
      class DeliriumVigilance < Abilities::Static::KeywordGrant
        keyword_grants Keywords::VIGILANCE

        conditions { source.controller.graveyard.delirium? }
        applicable_targets { [source] }
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [DeliriumBoost, DeliriumVigilance]
    end
  end
end
