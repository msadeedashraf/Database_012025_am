### Inserting One Document 

db.monkeys.insertOne(
{
Name: "Baboon",
    Location: "Africa & Asia",
    Details: "Baboons are African and Arabian Old World monkeys belonging to the genus Papio, part of the subfamily Cercopithecinae.",
    Image: "https://raw.githubusercontent.com/jamesmontemagno/app-monkeys/master/baboon.jpg",
    Population: 10000,
    Latitude: -8.783195,
    Longitude: 34.508523
}
)

### Inserting Many Document 

db.monkeys.insertMany(
[
{
    "Name": "Capuchin Monkey",
    "Location": "Central & South America",
    "Details": "The capuchin monkeys are New World monkeys of the subfamily Cebinae. Prior to 2011, the subfamily contained only a single genus, Cebus.",
    "Image": "https://raw.githubusercontent.com/jamesmontemagno/app-monkeys/master/capuchin.jpg",
    "Population": 23000,
    "Latitude": 12.769013,
    "Longitude": -85.602364
  },
  {
    "Name": "Blue Monkey",
    "Location": "Central and East Africa",
    "Details": "The blue monkey or diademed monkey is a species of Old World monkey native to Central and East Africa, ranging from the upper Congo River basin east to the East African Rift and south to northern Angola and Zambia",
    "Image": "https://raw.githubusercontent.com/jamesmontemagno/app-monkeys/master/bluemonkey.jpg",
    "Population": 12000,
    "Latitude": 1.957709,
    "Longitude": 37.297204
  }]
)

