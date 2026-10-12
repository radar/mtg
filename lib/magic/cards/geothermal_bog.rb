module Magic
  module Cards
    GeothermalBog = Card("Geothermal Bog") do
      type T::Land, T::Lands::Swamp, T::Lands::Mountain
      enters_tapped
    end
  end
end
