import '../models/restaurant.dart';
import '../models/dish.dart';

final List<Restaurant> dummyRestaurants = [
  Restaurant(
    id: '1',
    title: 'North Street Tavern',
    address: '1128 North St, White Plains',
    image: 'https://via.placeholder.com/150',
    cuisine: 'American',
  ),
  Restaurant(
    id: '2',
    title: 'Eataly',
    address: '800 Boylston St, Boston',
    image: 'https://via.placeholder.com/150',
    cuisine: 'Italian',
  ),
  Restaurant(
    id: '3',
    title: 'Nan Xiang Xiao Long Bao',
    address: 'Queens, New York',
    image: 'https://via.placeholder.com/150',
    cuisine: 'Chinese',
  ),
];

final List<Dish> dummyDishes = [
  Dish(
    id: '1',
    restaurantId: '1',
    title: 'Yorkshire Lamb Patties',
    slogan: 'Lamb patties which melt in your mouth, and are quick and easy to make.',
    price: 14.00,
    image: 'https://via.placeholder.com/150',
    cuisine: 'American',
  ),
  Dish(
    id: '2',
    restaurantId: '1',
    title: 'Lobster Thermidor',
    slogan: 'Lobster Thermidor is a French dish of lobster meat cooked in a rich wine sauce.',
    price: 36.00,
    image: 'https://via.placeholder.com/150',
    cuisine: 'American',
  ),
  Dish(
    id: '3',
    restaurantId: '2',
    title: 'Chicken Madeira',
    slogan: 'Chicken Madeira, like Chicken Marsala, is made with chicken, mushrooms, and a special fortified wine.',
    price: 23.00,
    image: 'https://via.placeholder.com/150',
    cuisine: 'Italian',
  ),
];
