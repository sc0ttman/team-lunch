require 'spec_helper'

describe 'Restaurant' do
  let (:stock) { { vegetarian: 5, fish_free: 1, no_restriction: 94 } }
  let (:restaurant) { Restaurant.new(name: 'Ruby Tuesday', rating: 5, total_stock_limit: 100, stock: stock) }

  context 'initialize' do
    it 'has a name' do
      expect(restaurant.name).to eq 'Ruby Tuesday'
    end

    it 'has a rating' do
      expect(restaurant.rating).to eq 5
    end

    it 'has a total_stock_limit' do
      expect(restaurant.total_stock_limit).to eq 100
    end

    it 'has available_stock' do
      expect(restaurant.available_stock).to match_array({ vegetarian: 5, fish_free: 1, no_restriction: 94 })
    end
  end

  context 'fulfilling orders (cooking meals)' do
    before { restaurant.cook_meal(:no_restriction) }

    it 'checks if the restaurant is able to cook a meal type' do
      expect(restaurant.can_cook_meal?(:popcorn)).to eq false
      expect(restaurant.can_cook_meal?(:vegetarian)).to eq true
    end

    it 'decreases a counter when a certan meal type is cooked' do
      expect(restaurant.cook_meal(:fish_free)).to eq 0 # had 1, now 0
      expect(restaurant.cook_meal(:fish_free)).to eq false # None left so returns false
    end

    it 'increases the filled orders counter' do
      expect(restaurant.filled_orders).to match_array({no_restriction: 1})
    end
  end

  context 'output of cooked meals' do
    it 'outputs the human-readable meal type and count of a single meal type' do
      expect(restaurant.translate_filled_order(:fish_free, 2)).to eq '2 fish free'
      expect(restaurant.translate_filled_order(:no_restriction, 5)).to eq '5 others'
      expect(restaurant.translate_filled_order(:no_restriction,  1)).to eq '1 other' # note no plural
    end

    it 'outputs a sentence of all cooked meal types' do
      restaurant.cook_meal(:vegetarian)
      restaurant.cook_meal(:no_restriction)
      restaurant.cook_meal(:fish_free)

      expect(restaurant.filled_orders_sentence).to eq 'Ruby Tuesday (1 vegetarian + 1 other + 1 fish free)'
    end
  end
end
