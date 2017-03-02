# Models all meals including non-restricted

class Meal
  attr_accessor :restriction

  # Keys to human-readable names
  RESTRICTIONS = {
    no_restriction: 'Other',
    vegetarian: 'Vegetarian',
    gluten_free: 'Gluten free',
    nut_free: 'Nut free',
    fish_free: 'Fish free'
  }.freeze

  def initialize(restriction: :no_restriction)
    raise ArgumentError.new("Invalid restriction") unless RESTRICTIONS.has_key?(restriction)
    @restriction = restriction
  end

  def to_s
    RESTRICTIONS[restriction]
  end
end
