##### Author: Scott Luedtke
##### Date: Mar 2, 2017

### Problem

We're ordering meals for a team lunch. Every member in the team needs one meal, some have dietary restrictions such as vegetarian, gluten free, nut free, and fish free. We have a list of restaurants which serve meals that satisfy some of these restrictions. Each restaurant has a rating, and a limited amount of meals in stock that they can make today. Implement an object oriented system with automated tests that can automatically produce the best possible meal orders with reasonable assumptions.

### Example:

Team needs: total 50 meals including 5 vegetarians and 7 gluten free.
Restaurants: Restaurant A has a rating of 5/5 and can serve 40 meals including 4 vegetarians,
Restaurant B has a rating of 3/5 and can serve 100 meals including 20 vegetarians, and 20 gluten free.

Expected meal orders: Restaurant A (4 vegetarian + 36 others), Restaurant B (1 vegetarian + 7 gluten free + 2 others)

### Assumptions
* Input data will be loaded using `.yml` files like those in `config` folder
* Data will load properly. All required params will be passed to objects.
* No error messages are shown when restaurants cannot fulfill the needs of a Team

### Usage

```
bundle install
```

Copy and customize
```
config/input.yml.example
```

From console run:
```
$ bundle exec ruby team_lunch.rb config/input.yml.example
=> Expected meal orders: Restaurant A (4 vegetarian + 36 others), Restaurant B (1 vegetarian + 7 gluten free + 2 others)
```

### Testing
```
$ bundle exec rspec spec
....................

Finished in 0.00556 seconds (files took 0.07769 seconds to load)
20 examples, 0 failures
```
