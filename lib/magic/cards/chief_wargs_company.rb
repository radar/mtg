module Magic
  module Cards
    ChiefWargsCompany = Creature("Chief Warg's Company") do
      cost generic: 1, black: 1, green: 1
      creature_type("Wolf")
      keywords :trample
      power 5
      toughness 3
    end

    class ChiefWargsCompany < Creature
      WolfToken = Token.create "Wolf" do
        creature_type "Wolf"
        power 2
        toughness 2
        colors :green
      end

      # "This creature can't attack unless you control two or more other Wolves."
      def can_attack?
        super && (controller || owner).creatures.select { _1.type?("Wolf") && _1.card != self }.count >= 2
      end

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          trigger_effect(:create_token, token_class: ChiefWargsCompany::WolfToken)
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
    end
  end
end
