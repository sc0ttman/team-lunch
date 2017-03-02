require 'rspec'
require 'active_support/inflector'

# Classes
# Team (handles input/output and contruction of data)
# DietaryRestriction
# Restuaurant
# Order (or just a method on Team. Team.lunch_order())

# Inputs
# Team needs
# Restaurants

# Assumptions
# - Fill orders with highest rated restuarants first


# Holds our team and restaurant info
# In charge of reading input and creating instances of objects
class Team
  attr_accessor :total_meals, :required_meals, :restaurants, :restaurants_used
  def initialize(total_meals:, specality_meal_data:, restaurant_data:[])
    @total_meals      = total_meals
    @required_meals   = create_restrictions_hash(total_meals, specality_meal_data)
    @restaurants      = restaurantify(restaurant_data)
    @restaurants_used = [] # Restaurants used to fill meals
  end

  def unfilled_meals_count
    required_meals.values.inject { |a, b| a + b }
  end

  def generate_lunch_orders()
    until unfilled_meals_count <= 0
      restaurants.each do |rest| # Starting with highest rated
        required_meals.keys.each do |meal_type|
          until !rest.can_cook_meal?(meal_type) || required_meals[meal_type] <= 0
            rest.cook_meal(meal_type)
            required_meals[meal_type] -= 1
            @restaurants_used << rest unless @restaurants_used.include? rest
          end
        end
      end
    end
  end

  def print_lunch_orders()
    @restaurants_used.collect{ |rest| rest.filled_orders_sentence }.join(', ')
  end

  private

  # Builds hash contaning all needed meal types and their counts.
  # Manually generates the 'no_restriction' meal type and count using the total_meals count
  # Ex converts [[:vegetarian, 5], [:fish_free, 1]]  to { vegetarian: 5, fish_free: 1, no_restriction: 94 } knowing the total of 100
  def create_restrictions_hash(total_meals, data)
    required_meals = data.collect{ |rule| { DietaryRestriction.new(restriction: rule[0]).restriction => rule[1] } }
    required_meals = required_meals.reduce({}, :merge) # http://stackoverflow.com/a/11856612/6288938

    # Manually create 'no_restriction' restriction and count by subtracting restricted meals totals from total_stock_limit
    restriction_meal_total_count = required_meals.values.inject { |a, b| a + b }
    required_meals[DietaryRestriction.new().restriction] = total_meals - restriction_meal_total_count
    required_meals
  end

  def restaurantify(data)
    restaurants = []
    data.each do |restaurant|
      restaurants << Restaurant.new(name: restaurant[:name], rating: restaurant[:rating], total_stock_limit: restaurant[:total_stock_limit],
          stock: create_restrictions_hash(restaurant[:total_stock_limit], restaurant[:stock_data] ) )
    end
    # order by highest rating decending
    restaurants.sort!{ |a,b| a.rating <=> b.rating }.reverse
  end
end

# class Meal
#   attr_accessor :restriction
#
#   def initialize(restriction: nil)
#     @restriction = restriction
#   end
#
#   def has_restriction?
#     @restriction ? restriction.to_s : false
#   end
# end

# Essentially a meal. TODO: maybe rename to Meal
class DietaryRestriction
  attr_accessor :restriction

  # Keys to human-readable names
  RESTRICTIONS = {
    no_restriction: 'Other', # Currently valid. May change this.
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

# Expects a rating and a set of rules describing what it is able to output
# Keeps track of meal type counts
# Input stock_data:
#  2d array of meal restriction keys and counts:  [[:vegetarian, 5], [:fish_free, 1]]
#
class Restaurant
  attr_accessor :name, :rating, :total_stock_limit, :available_stock, :filled_orders
  def initialize(name:, rating:0, total_stock_limit:0, stock:{})
    @name              = name
    @rating            = rating
    @total_stock_limit = total_stock_limit
    @available_stock   = stock
    @filled_orders     = {}
  end

  def can_cook_meal?(restriction)
    @available_stock.has_key?(restriction) && @available_stock[restriction] > 0
  end

  def cook_meal(restriction)
    return false unless can_cook_meal?(restriction)

    @filled_orders[restriction] = @filled_orders.has_key?(restriction) ? @filled_orders[restriction] += 1 : 1
    @available_stock[restriction] -= 1
  end

  def filled_orders_sentence()
    #  (has a rating of #{@rating}/5 and can serve #{total_stock_limit} meals)
    "#{@name} (#{translate_filled_orders()})"
  end

  def translate_filled_orders
    @filled_orders.collect{|key, count| translate_filled_order(key, count)}.join(' + ')
  end

  def translate_filled_order(key,count)
    "#{count} #{DietaryRestriction::RESTRICTIONS[key].downcase.pluralize(count)}"
  end

  # private
  # def populate_restrictions(data)
  #   restrictions = data.collect{ |rule| { DietaryRestriction.new(restriction: rule[0]).restriction => rule[1] } }
  #   restrictions = restrictions.reduce({}, :merge) # http://stackoverflow.com/a/11856612/6288938
  #
  #   # Manually create 'no_restriction' restriction and count by subtracting restricted meals totals from total_stock_limit
  #   restriction_meal_total_count = restrictions.values.inject { |a, b| a + b }
  #   restrictions[DietaryRestriction.new().restriction] = @total_stock_limit - restriction_meal_total_count
  #   restrictions
  # end
end



##################################################################
# Specs

describe 'team_lunch' do
  # describe 'Meal' do
  #   let(:meal) { Meal.new }
  #   let(:restricted_meal) { Meal.new( restriction: DietaryRestriction.new(restriction: :gluten_free)) }
  #
  #   it "returns false when no restriction" do
  #     expect(meal.has_restriction?).to eq false
  #   end
  #
  #   it "returns a restriction string when one is set" do
  #     expect(restricted_meal.has_restriction?).to eq DietaryRestriction::RESTRICTIONS[:gluten_free]
  #   end
  # end

  describe 'DietaryRestriction' do
    let(:restriction) { DietaryRestriction.new() }
    let(:invalid_restriction) { DietaryRestriction.new(:candy) }

    it "sets the restriction_type to :no_restriction when nothing passed in" do
      expect(restriction.to_s).to eq DietaryRestriction::RESTRICTIONS[:no_restriction]
    end

    it "throws an error if no restriction is passed" do
      expect{invalid_restriction}.to raise_error(ArgumentError)
    end
  end

  describe 'Restaurant' do
    let (:stock) { { vegetarian: 5, fish_free: 1, no_restriction: 94 } }
    let (:restaurant) { Restaurant.new(name: 'Big papas', rating: 5, total_stock_limit: 100, stock: stock) }

    context 'utility methods' do
      it 'processes stock data' do
        expect(restaurant.available_stock.is_a?(Hash)).to eq true
      end

      it 'creates proper available_stock hash' do
        expect(restaurant.available_stock).to match_array({ vegetarian: 5, fish_free: 1, no_restriction: 94 })
      end

      it 'has a name' do
        expect(restaurant.name).to eq 'Big papas'
      end

      it 'has a rating' do
        expect(restaurant.rating).to eq 5
      end

      it 'has a total_stock_limit' do
        expect(restaurant.total_stock_limit).to eq 100
      end
    end

    context '#can_cook_meal?' do
      it 'checks if the restaurant is able to cook a meal type' do
        expect(restaurant.can_cook_meal?(:popcorn)).to eq false
        expect(restaurant.can_cook_meal?(:vegetarian)).to eq true
      end
    end

    context '#cook_meal' do
      before do
        restaurant.cook_meal(:no_restriction)
      end

      it 'decreases a counter when a certan meal type is cooked' do
        expect(restaurant.cook_meal(:fish_free)).to eq 0
        expect(restaurant.cook_meal(:fish_free)).to eq false # Not possible so returns false
      end

      it 'increases the filled orders counter' do
        expect(restaurant.filled_orders).to match_array({no_restriction: 1})
      end
    end
  end

  describe 'Team' do
    let(:team_requirements) { [[:vegetarian, 5], [:gluten_free, 1]] }
    let(:rest1) { { name: 'Restaurant A', rating: 5, total_stock_limit: 40, stock_data: [[:vegetarian, 4], [:fish_free, 1]] } }
    let(:rest2) { { name: 'Restaurant B', rating: 4, total_stock_limit: 80, stock_data: [[:vegetarian, 20], [:gluten_free, 7]] } }
    let(:rest3) { { name: 'Restaurant C', rating: 1, total_stock_limit: 20, stock_data: [[:gluten_free, 7]] } }
    let(:rest4) { { name: 'Restaurant D', rating: 5, total_stock_limit: 10, stock_data: [[:nut_free, 6], [:fish_free, 2]] } }

    let(:team) { Team.new(total_meals: 50, specality_meal_data: team_requirements , restaurant_data:[rest1, rest2, rest3,  rest4]) }

    context 'utility methods' do
      it 'processes required_meal data' do
        expect(team.required_meals).to match_array({ vegetarian: 5, gluten_free: 1, no_restriction: 44 })
      end

      it 'processes restaurant data' do
        expect(team.restaurants.size).to eq 4
      end

      it 'orders restaurants by rating' do
        expect(team.restaurants.collect{|rest| rest.rating}).to eq([5,5,4,1])
      end
    end

    context '#unfilled_meals_count' do
      it 'returns count of meals not yet cooked' do
        expect(team.unfilled_meals_count).to eq 50
      end
    end

    context '#generate_lunch_orders' do
      before do
        team.generate_lunch_orders
      end
      it 'returns count of meals not yet cooked' do
        expect(team.restaurants_used.empty?).to eq false
        expect(team.restaurants_used.length).to eq 3
      end
    end

    context '#print_lunch_orders' do
      before do
        team.generate_lunch_orders
      end
      it 'returns count of meals not yet cooked' do
        expect(team.print_lunch_orders).to eq "Restaurant D (2 others), Restaurant A (4 vegetarians + 35 others), Restaurant B (1 vegetarian + 1 gluten free + 7 others)"
      end
    end

  end

end
