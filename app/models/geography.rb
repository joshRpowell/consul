class Geography < ApplicationRecord
  validates :name, presence: true
  validates :color, presence: true
  validates_with GeojsonFormat

  has_many :headings, class_name: Budget::Heading, dependent: :nullify

  def self.geographies_with_active_headings
    active_headings = {}

    if Budget.current.present?
      Budget.current.headings.each do |active_heading|
        if active_heading.geography
          active_headings[active_heading.geography_id] = active_heading.id
        end
      end
    end

    active_headings
    #headings_with_geographies = Budget.current.headings.select { |heading| heading.geograhpy.present? }
    #headings_with_geographies.map { |heading| [heading.geography_id, heading.id] }.to_h
  end

  def parsed_outline_points
    if geojson.present?
      coordinates_array = JSON.parse(geojson)["geometry"]["coordinates"]

      if geojson.match(/"coordinates"\s*:\s*\[{4}/)
        coordinates_array = coordinates_array.reduce([], :concat).reduce([], :concat)
      elsif geojson.match(/"coordinates"\s*:\s*\[{3}/)
        coordinates_array = coordinates_array.reduce([], :concat)
      end

      coordinates_array.map { |coordinates| [coordinates.second, coordinates.first] }
    else
      []
    end
  end
end
