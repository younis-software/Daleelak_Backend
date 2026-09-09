const mockPlaces = [
  {
    id: 1,
    name: "Cinema City",
    description: "Modern multiplex cinema with latest blockbusters and premium screens",
    rating: 4.5,
    category: "Entertainment",
    address: "123 Main Street, Downtown",
    imageUrl: "https://example.com/cinema.jpg"
  },
  {
    id: 2,
    name: "Adventure Park",
    description: "Outdoor adventure park with zip lines, climbing walls, and obstacle courses",
    rating: 4.8,
    category: "Outdoor Activities",
    address: "456 Park Avenue, Green District",
    imageUrl: "https://example.com/adventure.jpg"
  }
];

export const getPlaces = (req, res) => {
  res.json(mockPlaces);
};

export const getPlaceById = (req, res) => {
  const place = mockPlaces.find(p => p.id === parseInt(req.params.id));
  if (!place) {
    return res.status(404).json({ message: 'Place not found' });
  }
  res.json(place);
};