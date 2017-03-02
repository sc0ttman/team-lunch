require 'spec_helper'

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
