require 'spec_helper'

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

  context 'fulfilling orders (cooking meals)' do
    before { restaurant.cook_meal(:no_restriction) }

    it 'checks if the restaurant is able to cook a meal type' do
      expect(restaurant.can_cook_meal?(:popcorn)).to eq false
      expect(restaurant.can_cook_meal?(:vegetarian)).to eq true
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
