const beaches = [
  // Tamil Nadu
  {
    id: "1",
    name: "Marina Beach",
    location: "Chennai, Tamil Nadu",
    temperature: 32.5,
    waveHeight: 1.2,
    oceanCurrents: "Moderate",
    isSafe: true,
    latitude: 13.05,
    longitude: 80.2824,
    description:
      "Marina Beach is a natural urban beach along the Bay of Bengal. The beach runs from Fort St. George in the north to Foreshore Estate in the south, making it the longest natural urban beach in India.",
  },
  {
    id: "2",
    name: "Elliot's Beach",
    location: "Chennai, Tamil Nadu",
    temperature: 32.0,
    waveHeight: 1.0,
    oceanCurrents: "Mild",
    isSafe: true,
    latitude: 12.9982,
    longitude: 80.2721,
    description:
      "Also known as Besant Nagar Beach or Bessie, it forms the end-point of the Marina Beach shore and is less crowded than the Marina.",
  },
  // Goa
  {
    id: "3",
    name: "Calangute Beach",
    location: "North Goa",
    temperature: 29.8,
    waveHeight: 2.5,
    oceanCurrents: "Strong",
    isSafe: false,
    latitude: 15.5491,
    longitude: 73.7632,
    description:
      "Calangute is the largest beach in North Goa and one of the most popular beaches in the state. Due to its popularity, it is often crowded and busy.",
  },
  {
    id: "4",
    name: "Baga Beach",
    location: "North Goa",
    temperature: 29.5,
    waveHeight: 2.2,
    oceanCurrents: "Moderate to Strong",
    isSafe: false,
    latitude: 15.5553,
    longitude: 73.7539,
    description:
      "Baga Beach is a popular beach and tourist destination located in North Goa. It is known for its nightlife, water sports, and restaurants.",
  },
  {
    id: "5",
    name: "Anjuna Beach",
    location: "North Goa",
    temperature: 29.7,
    waveHeight: 1.8,
    oceanCurrents: "Moderate",
    isSafe: false,
    latitude: 15.5752,
    longitude: 73.7399,
    description:
      "Anjuna Beach is famous for its trance parties held during tourist season. It was also the birthplace of Goa trance.",
  },
  {
    id: "6",
    name: "Palolem Beach",
    location: "South Goa",
    temperature: 29.3,
    waveHeight: 0.9,
    oceanCurrents: "Mild",
    isSafe: true,
    latitude: 15.01,
    longitude: 74.0232,
    description:
      "Palolem is a crescent-shaped beach in South Goa, surrounded by a thick forest of coconut palms. It is considered one of the most beautiful beaches in Goa.",
  },
  {
    id: "7",
    name: "Colva Beach",
    location: "South Goa",
    temperature: 29.6,
    waveHeight: 1.2,
    oceanCurrents: "Moderate",
    isSafe: true,
    latitude: 15.2797,
    longitude: 73.9173,
    description:
      "Colva Beach is the oldest and largest beach in South Goa. It is known for its white sand and clear waters.",
  },
  // Andaman and Nicobar Islands
  {
    id: "8",
    name: "Radhanagar Beach",
    location: "Havelock Island, Andaman",
    temperature: 30.2,
    waveHeight: 0.8,
    oceanCurrents: "Mild",
    isSafe: true,
    latitude: 11.983,
    longitude: 92.9518,
    description:
      "Radhanagar Beach is a popular tourist destination in Andaman, known for its white sand, turquoise waters and lush green forest. It has been rated as one of the best beaches in Asia.",
  },
  {
    id: "9",
    name: "Elephant Beach",
    location: "Havelock Island, Andaman",
    temperature: 30.0,
    waveHeight: 0.7,
    oceanCurrents: "Mild",
    isSafe: true,
    latitude: 12.011,
    longitude: 92.9461,
    description:
      "Elephant Beach is known for its vibrant coral reefs and is one of the best snorkeling spots in the Andaman Islands.",
  },
  {
    id: "10",
    name: "Corbyn's Cove",
    location: "Port Blair, Andaman",
    temperature: 30.5,
    waveHeight: 1.0,
    oceanCurrents: "Moderate",
    isSafe: true,
    latitude: 11.6469,
    longitude: 92.7461,
    description:
      "Corbyn's Cove is a serene beach located 8 km from Port Blair, the capital city of the Andaman and Nicobar Islands. It is a coconut palm-fringed beach ideal for swimming and sunbathing.",
  },
  // Kerala
  {
    id: "11",
    name: "Kovalam Beach",
    location: "Thiruvananthapuram, Kerala",
    temperature: 28.5,
    waveHeight: 1.8,
    oceanCurrents: "Moderate to Strong",
    isSafe: false,
    latitude: 8.3988,
    longitude: 76.9781,
    description:
      "Kovalam is a small coastal town in the southern Indian state of Kerala, south of Thiruvananthapuram. At the southern end of Lighthouse Beach is a striped lighthouse with a viewing platform.",
  },
  {
    id: "12",
    name: "Varkala Beach",
    location: "Thiruvananthapuram, Kerala",
    temperature: 28.7,
    waveHeight: 1.7,
    oceanCurrents: "Moderate",
    isSafe: false,
    latitude: 8.7378,
    longitude: 76.7164,
    description:
      "Varkala Beach, also known as Papanasam Beach, is a cliff beach in Kerala. The 2000-year-old Janardana Swami Temple is located near the beach.",
  },
  {
    id: "13",
    name: "Cherai Beach",
    location: "Kochi, Kerala",
    temperature: 29.0,
    waveHeight: 1.2,
    oceanCurrents: "Mild to Moderate",
    isSafe: true,
    latitude: 10.1368,
    longitude: 76.1797,
    description:
      "Cherai Beach is a beautiful beach located in Kochi. It is known for its clean water and golden sand. It is also one of the few places where you can see the backwaters and the sea together.",
  },
  {
    id: "14",
    name: "Marari Beach",
    location: "Alappuzha, Kerala",
    temperature: 28.8,
    waveHeight: 1.5,
    oceanCurrents: "Moderate",
    isSafe: false,
    latitude: 9.596,
    longitude: 76.2962,
    description:
      "Marari Beach is a secluded beach known for its serene atmosphere and fishing village. It is an ideal place to relax and enjoy the natural beauty of Kerala.",
  },
  // Odisha
  {
    id: "15",
    name: "Puri Beach",
    location: "Puri, Odisha",
    temperature: 31.0,
    waveHeight: 1.5,
    oceanCurrents: "Moderate",
    isSafe: false,
    latitude: 19.8016,
    longitude: 85.8217,
    description:
      "Puri Beach is a beach in the city of Puri in the state of Odisha, India. It is on the shore of the Bay of Bengal. It is known for being a tourist attraction and a Hindu sacred place.",
  },
  {
    id: "16",
    name: "Chandipur Beach",
    location: "Balasore, Odisha",
    temperature: 30.8,
    waveHeight: 1.0,
    oceanCurrents: "Mild",
    isSafe: true,
    latitude: 21.4458,
    longitude: 87.0229,
    description:
      "Chandipur Beach is known for its unique phenomenon of the receding tide that extends up to 5 km into the sea, allowing visitors to walk on the seabed.",
  },
  {
    id: "17",
    name: "Gopalpur Beach",
    location: "Ganjam, Odisha",
    temperature: 30.5,
    waveHeight: 1.3,
    oceanCurrents: "Moderate",
    isSafe: true,
    latitude: 19.2583,
    longitude: 84.9075,
    description:
      "Gopalpur is a beach town and a notified area council in Ganjam district in the Indian state of Odisha. It is a seaport famous for its beach.",
  },
  // Maharashtra
  {
    id: "18",
    name: "Juhu Beach",
    location: "Mumbai, Maharashtra",
    temperature: 29.5,
    waveHeight: 1.4,
    oceanCurrents: "Moderate",
    isSafe: false,
    latitude: 19.0883,
    longitude: 72.8268,
    description:
      "Juhu Beach is one of the most famous beaches in Mumbai. It is a popular tourist attraction and is known for its street food and celebrity homes.",
  },
];

module.exports = { beaches };
