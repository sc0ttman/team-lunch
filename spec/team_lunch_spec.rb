require 'spec_helper'

describe 'team_lunch' do

  describe 'Meal' do
    let(:restriction) { Meal.new() }
    let(:invalid_restriction) { Meal.new(:candy) }

    it "sets the restriction_type to :no_restriction when nothing passed in" do
      expect(restriction.to_s).to eq Meal::RESTRICTIONS[:no_restriction]
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

    context 'unfilled meals' do
      before { team.required_meals = { no_restriction: 5, vegetarian: 0, fish_free: 0 }}

      it 'returns count of meals not yet cooked' do
        expect(team.unfilled_meals_count).to eq 5
      end

      it 'returns all meal types that are still required to fill' do
        expect(team.unfilled_meals).to match_array({ no_restriction: 5 })
      end
    end

    context 'generating lunch orders' do
      before { team.generate_lunch_orders }

      it 'returns count of meals not yet cooked' do
        expect(team.restaurants_used.empty?).to eq false
        expect(team.restaurants_used.length).to eq 3
      end

      it 'prints results of ordered meals' do
        expect(team.print_lunch_orders).to eq "Restaurant D (2 others), Restaurant A (4 vegetarian + 35 others), Restaurant B (1 vegetarian + 1 gluten free + 7 others)"
      end
    end

  end

end
