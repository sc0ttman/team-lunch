require 'spec_helper'

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
