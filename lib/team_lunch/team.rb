# Holds our team and restaurant info
# In charge of reading input and creating instances of objects

class Team
  attr_accessor :total_meals, :required_meals, :restaurants, :restaurants_used
  def initialize(total_meals:, specality_meal_data:, restaurant_data:[])
    @total_meals      = total_meals
    @required_meals   = create_meal_type_hash(total_meals, specality_meal_data)
    @restaurants      = restaurantify(restaurant_data) # Ordered by highest to lowest rating
    @restaurants_used = [] # Restaurants used to fill meals
  end

  def unfilled_meals_count
    required_meals.values.reduce(:+)
  end

  def unfilled_meals
    required_meals.reject{ |k,v| v <= 0 }
  end

  def generate_lunch_orders
    until unfilled_meals_count <= 0
      restaurants.each do |restaurant| # Starting with highest rated
        unfilled_meals.each do |meal_type, count| # Only check for meals we still need
          until !restaurant.can_cook_meal?(meal_type) || required_meals[meal_type] <= 0
            restaurant.cook_meal(meal_type) # restaurant will keep track of meals it cooked
            required_meals[meal_type] -= 1 # team keeps track of meals it still needs to get cooked
            @restaurants_used << restaurant unless @restaurants_used.include? restaurant # TODO: Could use Set for uniqueness
          end
        end
      end
    end
  end

  def print_lunch_orders
    @restaurants_used.collect{ |restaurant| restaurant.filled_orders_sentence }.join(', ')
  end

  private

  # Builds hash contaning all needed meal types and their counts.
  # Manually generates the 'no_restriction' meal type and count using the total_meals count
  # Ex converts [[:vegetarian, 5], [:fish_free, 1]]  to { vegetarian: 5, fish_free: 1, no_restriction: 94 } knowing the total of 100
  def create_meal_type_hash(total_meals, data)
    required_meals = data.collect{ |rule| { Meal.new(restriction: rule[0]).restriction => rule[1] } }
    required_meals = required_meals.reduce({}, :merge) # http://stackoverflow.com/a/11856612/6288938

    # Manually create 'no_restriction' restriction and count by subtracting restricted meals totals from total_stock_limit
    restriction_meal_total_count = required_meals.values.inject { |a, b| a + b }
    required_meals[Meal.new().restriction] = total_meals - restriction_meal_total_count
    required_meals
  end

  # Sandi Metzify :)
  def restaurantify(data)
    restaurants = []
    data.each do |restaurant|
      restaurants << Restaurant.new(name: restaurant[:name], rating: restaurant[:rating], total_stock_limit: restaurant[:total_stock_limit],
          stock: create_meal_type_hash(restaurant[:total_stock_limit], restaurant[:stock_data] ) )
    end
    # order by rating decending
    restaurants.sort!{ |a,b| a.rating <=> b.rating }.reverse
  end
end
