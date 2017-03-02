# Keeps track of what a restaurant can and has cooked.
# Builds strings used in output of orders.
# Input
#  stock:
#    Hash of meal types and counts that this restaurant is currently able to cook
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

  # Is this restaurant still able to fullfill this meal order?
  def can_cook_meal?(restriction)
    @available_stock.has_key?(restriction) && @available_stock[restriction] > 0
  end

  # Cook the meal and update the count
  def cook_meal(restriction)
    return false unless can_cook_meal?(restriction)

    @filled_orders[restriction] = @filled_orders.has_key?(restriction) ? @filled_orders[restriction] += 1 : 1
    @available_stock[restriction] -= 1
  end

  # Output helper methods
  # Eg: 'Restaurant A (4 vegetarian + 36 others)'
  def filled_orders_sentence
    "#{@name} (#{@filled_orders.collect{|key, count| translate_filled_order(key, count)}.join(' + ')})"
  end

  # Eg: '4 vegetarian'
  def translate_filled_order(key,count)
    meal_translation = Meal::RESTRICTIONS[key].downcase
    meal_translation = meal_translation.pluralize(count) if key == :no_restriction # eg: '4 others'

    "#{count} #{meal_translation}"
  end

end
