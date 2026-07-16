import CoreLocation
import Foundation

/// A searchable US location for the V2 Connect screen.
struct USCity: Identifiable, Equatable {
    let name: String
    let state: String
    let latitude: Double
    let longitude: Double
    /// Waterfront cities: compass bearing (degrees clockwise from north)
    /// pointing inland. People pins fan around this direction only, so
    /// nobody ends up floating in a lake or the ocean.
    let inlandBearing: Double?
    /// Half-width of the land wedge around `inlandBearing`.
    let wedgeHalfAngle: Double
    /// Shrinks the pin spread for compact geographies (islands, peninsulas).
    let pinScale: Double

    init(
        name: String,
        state: String,
        latitude: Double,
        longitude: Double,
        inlandBearing: Double? = nil,
        wedgeHalfAngle: Double = 75,
        pinScale: Double = 1
    ) {
        self.name = name
        self.state = state
        self.latitude = latitude
        self.longitude = longitude
        self.inlandBearing = inlandBearing
        self.wedgeHalfAngle = wedgeHalfAngle
        self.pinScale = pinScale
    }

    var id: String { "\(name), \(state)" }
    var label: String { "\(name), \(state)" }
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: USCity, rhs: USCity) -> Bool { lhs.id == rhs.id }
}

/// V2 is US-only: search resolves to a US city, calls out known foreign
/// places explicitly, and rejects everything else.
enum USPlaces {
    enum Lookup: Equatable {
        case us(USCity)
        case foreign(String)
        case unknown
    }

    static func lookup(_ rawQuery: String) -> Lookup {
        let query = normalize(rawQuery)
        guard query.count >= 2 else { return .unknown }

        // Exact "city", "city st", or "city state" match wins.
        if let city = cities.first(where: { matches(city: $0, query: query, exact: true) }) {
            return .us(city)
        }
        // A state name lands you in its best-known city.
        if let cityName = stateCapitalsOfCulture[query],
           let city = cities.first(where: { normalize($0.name) == cityName }) {
            return .us(city)
        }
        // Prefix match so partial typing still resolves ("chic" → Chicago).
        if query.count >= 3,
           let city = cities.first(where: { matches(city: $0, query: query, exact: false) }) {
            return .us(city)
        }
        if let foreignName = foreignCities[query] {
            return .foreign(foreignName)
        }
        return .unknown
    }

    private static func matches(city: USCity, query: String, exact: Bool) -> Bool {
        let name = normalize(city.name)
        let state = normalize(city.state)
        let full = "\(name) \(state)"
        if exact {
            return query == name || query == full
        }
        return name.hasPrefix(query) || full.hasPrefix(query)
    }

    private static func normalize(_ text: String) -> String {
        var s = text.lowercased()
            .replacingOccurrences(of: ",", with: " ")
            .replacingOccurrences(of: ".", with: "")
        for suffix in [" usa", " us", " united states", " america"] {
            if s.hasSuffix(suffix) { s = String(s.dropLast(suffix.count)) }
        }
        return s.split(separator: " ").joined(separator: " ")
    }

    // MARK: Catalog

    static let cities: [USCity] = [
        USCity(name: "New York", state: "NY", latitude: 40.7128, longitude: -74.0060, inlandBearing: 300),
        USCity(name: "Los Angeles", state: "CA", latitude: 34.0522, longitude: -118.2437, inlandBearing: 25),
        USCity(name: "Chicago", state: "IL", latitude: 41.8781, longitude: -87.6298, inlandBearing: 250),
        USCity(name: "Houston", state: "TX", latitude: 29.7604, longitude: -95.3698, inlandBearing: 290),
        USCity(name: "Phoenix", state: "AZ", latitude: 33.4484, longitude: -112.0740),
        USCity(name: "Philadelphia", state: "PA", latitude: 39.9526, longitude: -75.1652, inlandBearing: 300),
        USCity(name: "San Antonio", state: "TX", latitude: 29.4241, longitude: -98.4936),
        USCity(name: "San Diego", state: "CA", latitude: 32.7157, longitude: -117.1611, inlandBearing: 60),
        USCity(name: "Dallas", state: "TX", latitude: 32.7767, longitude: -96.7970),
        USCity(name: "Austin", state: "TX", latitude: 30.2672, longitude: -97.7431),
        USCity(name: "Jacksonville", state: "FL", latitude: 30.3322, longitude: -81.6557, inlandBearing: 250),
        USCity(name: "San Jose", state: "CA", latitude: 37.3382, longitude: -121.8863, inlandBearing: 160),
        USCity(name: "San Francisco", state: "CA", latitude: 37.7749, longitude: -122.4194, inlandBearing: 178, wedgeHalfAngle: 22, pinScale: 0.9),
        USCity(name: "Columbus", state: "OH", latitude: 39.9612, longitude: -82.9988),
        USCity(name: "Fort Worth", state: "TX", latitude: 32.7555, longitude: -97.3308),
        USCity(name: "Indianapolis", state: "IN", latitude: 39.7684, longitude: -86.1581),
        USCity(name: "Charlotte", state: "NC", latitude: 35.2271, longitude: -80.8431),
        USCity(name: "Seattle", state: "WA", latitude: 47.6062, longitude: -122.3321, inlandBearing: 168, wedgeHalfAngle: 25, pinScale: 1.2),
        USCity(name: "Denver", state: "CO", latitude: 39.7392, longitude: -104.9903),
        USCity(name: "Washington", state: "DC", latitude: 38.9072, longitude: -77.0369, inlandBearing: 30),
        USCity(name: "Boston", state: "MA", latitude: 42.3601, longitude: -71.0589, inlandBearing: 260),
        USCity(name: "Nashville", state: "TN", latitude: 36.1627, longitude: -86.7816),
        USCity(name: "Detroit", state: "MI", latitude: 42.3314, longitude: -83.0458, inlandBearing: 315),
        USCity(name: "Portland", state: "OR", latitude: 45.5152, longitude: -122.6784, inlandBearing: 175, wedgeHalfAngle: 60),
        USCity(name: "Memphis", state: "TN", latitude: 35.1495, longitude: -90.0490, inlandBearing: 80),
        USCity(name: "Las Vegas", state: "NV", latitude: 36.1699, longitude: -115.1398),
        USCity(name: "Louisville", state: "KY", latitude: 38.2527, longitude: -85.7585, inlandBearing: 180),
        USCity(name: "Baltimore", state: "MD", latitude: 39.2904, longitude: -76.6122, inlandBearing: 320),
        USCity(name: "Milwaukee", state: "WI", latitude: 43.0389, longitude: -87.9065, inlandBearing: 260),
        USCity(name: "Albuquerque", state: "NM", latitude: 35.0844, longitude: -106.6504),
        USCity(name: "Tucson", state: "AZ", latitude: 32.2226, longitude: -110.9747),
        USCity(name: "Sacramento", state: "CA", latitude: 38.5816, longitude: -121.4944),
        USCity(name: "Kansas City", state: "MO", latitude: 39.0997, longitude: -94.5786),
        USCity(name: "Atlanta", state: "GA", latitude: 33.7490, longitude: -84.3880),
        USCity(name: "Miami", state: "FL", latitude: 25.7617, longitude: -80.1918, inlandBearing: 305, wedgeHalfAngle: 60),
        USCity(name: "Tampa", state: "FL", latitude: 27.9506, longitude: -82.4572, inlandBearing: 60, wedgeHalfAngle: 50),
        USCity(name: "Orlando", state: "FL", latitude: 28.5384, longitude: -81.3789),
        USCity(name: "Raleigh", state: "NC", latitude: 35.7796, longitude: -78.6382),
        USCity(name: "Minneapolis", state: "MN", latitude: 44.9778, longitude: -93.2650),
        USCity(name: "New Orleans", state: "LA", latitude: 29.9511, longitude: -90.0715, inlandBearing: 265, wedgeHalfAngle: 30, pinScale: 0.6),
        USCity(name: "Cleveland", state: "OH", latitude: 41.4993, longitude: -81.6944, inlandBearing: 170),
        USCity(name: "Pittsburgh", state: "PA", latitude: 40.4406, longitude: -79.9959),
        USCity(name: "St Louis", state: "MO", latitude: 38.6270, longitude: -90.1994, inlandBearing: 260),
        USCity(name: "Cincinnati", state: "OH", latitude: 39.1031, longitude: -84.5120, inlandBearing: 10),
        USCity(name: "Salt Lake City", state: "UT", latitude: 40.7608, longitude: -111.8910, inlandBearing: 140),
        USCity(name: "Boise", state: "ID", latitude: 43.6150, longitude: -116.2023),
        USCity(name: "Oklahoma City", state: "OK", latitude: 35.4676, longitude: -97.5164),
        USCity(name: "Omaha", state: "NE", latitude: 41.2565, longitude: -95.9345),
        USCity(name: "Birmingham", state: "AL", latitude: 33.5186, longitude: -86.8104),
        USCity(name: "Charleston", state: "SC", latitude: 32.7765, longitude: -79.9311, inlandBearing: 315, pinScale: 0.6),
        USCity(name: "Honolulu", state: "HI", latitude: 21.3099, longitude: -157.8581, inlandBearing: 285, wedgeHalfAngle: 40, pinScale: 0.5),
        USCity(name: "Anchorage", state: "AK", latitude: 61.2181, longitude: -149.9003, inlandBearing: 45, pinScale: 0.5),
        USCity(name: "Buffalo", state: "NY", latitude: 42.8864, longitude: -78.8784, inlandBearing: 75),
        USCity(name: "Richmond", state: "VA", latitude: 37.5407, longitude: -77.4360),
        USCity(name: "Hartford", state: "CT", latitude: 41.7658, longitude: -72.6734),
        USCity(name: "Providence", state: "RI", latitude: 41.8240, longitude: -71.4128, inlandBearing: 260, wedgeHalfAngle: 50, pinScale: 0.7),
        USCity(name: "Des Moines", state: "IA", latitude: 41.5868, longitude: -93.6250),
        USCity(name: "Little Rock", state: "AR", latitude: 34.7465, longitude: -92.2896),
        USCity(name: "Jackson", state: "MS", latitude: 32.2988, longitude: -90.1848),
        USCity(name: "Wichita", state: "KS", latitude: 37.6872, longitude: -97.3301),
    ]

    /// Typing a state name drops you in its best-known city.
    private static let stateCapitalsOfCulture: [String: String] = [
        "alabama": "birmingham", "alaska": "anchorage", "arizona": "phoenix",
        "arkansas": "little rock", "california": "los angeles", "colorado": "denver",
        "connecticut": "hartford", "florida": "miami", "georgia": "atlanta",
        "hawaii": "honolulu", "idaho": "boise", "illinois": "chicago",
        "indiana": "indianapolis", "iowa": "des moines", "kansas": "wichita",
        "kentucky": "louisville", "louisiana": "new orleans", "maryland": "baltimore",
        "massachusetts": "boston", "michigan": "detroit", "minnesota": "minneapolis",
        "mississippi": "jackson", "missouri": "kansas city", "nebraska": "omaha",
        "nevada": "las vegas", "new mexico": "albuquerque", "new york": "new york",
        "north carolina": "charlotte", "ohio": "columbus", "oklahoma": "oklahoma city",
        "oregon": "portland", "pennsylvania": "philadelphia", "rhode island": "providence",
        "south carolina": "charleston", "tennessee": "nashville", "texas": "austin",
        "utah": "salt lake city", "virginia": "richmond", "washington state": "seattle",
        "wisconsin": "milwaukee",
    ]

    /// Famous non-US places, recognized only so they can be turned away by name.
    private static let foreignCities: [String: String] = [
        "london": "London", "paris": "Paris", "tokyo": "Tokyo", "toronto": "Toronto",
        "vancouver": "Vancouver", "montreal": "Montreal", "mexico city": "Mexico City",
        "sydney": "Sydney", "melbourne": "Melbourne", "berlin": "Berlin",
        "madrid": "Madrid", "barcelona": "Barcelona", "rome": "Rome", "milan": "Milan",
        "amsterdam": "Amsterdam", "brussels": "Brussels", "dublin": "Dublin",
        "lisbon": "Lisbon", "munich": "Munich", "zurich": "Zurich", "geneva": "Geneva",
        "vienna": "Vienna", "prague": "Prague", "stockholm": "Stockholm", "oslo": "Oslo",
        "copenhagen": "Copenhagen", "helsinki": "Helsinki", "athens": "Athens",
        "istanbul": "Istanbul", "moscow": "Moscow", "cairo": "Cairo", "dubai": "Dubai",
        "mumbai": "Mumbai", "delhi": "Delhi", "bangkok": "Bangkok",
        "singapore": "Singapore", "hong kong": "Hong Kong", "beijing": "Beijing",
        "shanghai": "Shanghai", "seoul": "Seoul", "osaka": "Osaka", "taipei": "Taipei",
        "manila": "Manila", "jakarta": "Jakarta", "kuala lumpur": "Kuala Lumpur",
        "sao paulo": "São Paulo", "rio de janeiro": "Rio de Janeiro",
        "buenos aires": "Buenos Aires", "lima": "Lima", "bogota": "Bogotá",
        "santiago": "Santiago", "havana": "Havana", "nairobi": "Nairobi",
        "lagos": "Lagos", "cape town": "Cape Town", "johannesburg": "Johannesburg",
        "auckland": "Auckland", "edinburgh": "Edinburgh", "glasgow": "Glasgow",
        "manchester": "Manchester", "liverpool": "Liverpool",
    ]
}
