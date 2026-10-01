module Magic
  module Cards
    MammothBellow = Sorcery("Mammoth Bellow") do
      cost generic: 2, green: 1, blue: 1, red: 1
      harmonize Costs::Mana.new(generic: 5, green: 1, blue: 1, red: 1)
    end

    class MammothBellow < Sorcery
      ElephantToken = Token.create "Elephant" do
        creature_type "Elephant"
        power 5
        toughness 5
        colors :green
      end

      def resolve!
        trigger_effect(:create_token, token_class: ElephantToken)
      end
    end
  end
end
