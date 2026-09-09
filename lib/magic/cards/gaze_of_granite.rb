module Magic
  module Cards
    class GazeOfGranite < Sorcery
      card_name "Gaze of Granite"
      cost x: 1, black: 2, green: 1

      def resolve!(value_for_x:)
        battlefield.permanents.reject(&:land?).select { |permanent| permanent.mana_value <= value_for_x }.each do |permanent|
          trigger_effect(:destroy_target, target: permanent)
        end
      end
    end
  end
end