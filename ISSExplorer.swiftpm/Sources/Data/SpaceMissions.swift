import Foundation


struct SpaceMission {
    let id: String
    let name: String
    let year: Int
    let agency: String
    let destination: String
    let description: String
}
let allSpaceMissions: [SpaceMission] = [
    SpaceMission(
        id: "sputnik1",
        name: "Sputnik 1",
        year: 1957,
        agency: "USSR",
        destination: "Earth Orbit",
        description: "Humanity's first artificial satellite. Launched by the Soviet Union on October 4, 1957, it broadcast a simple radio beep that changed the world and ignited the Space Race."
    ),
    SpaceMission(
        id: "vostok1",
        name: "Vostok 1",
        year: 1961,
        agency: "USSR",
        destination: "Earth Orbit",
        description: "Yuri Gagarin became the first human in space on April 12, 1961. His single orbit of Earth lasted 108 minutes and remains one of history's greatest achievements."
    ),
    SpaceMission(
        id: "mercury_friendship7",
        name: "Mercury Friendship 7",
        year: 1962,
        agency: "NASA",
        destination: "Earth Orbit",
        description: "John Glenn became the first American to orbit Earth, completing three orbits in 4 hours 55 minutes. His mission restored US confidence during the Space Race."
    ),
    SpaceMission(
        id: "apollo11",
        name: "Apollo 11",
        year: 1969,
        agency: "NASA",
        destination: "Moon",
        description: "Neil Armstrong and Buzz Aldrin landed on the Sea of Tranquility on July 20, 1969. Armstrong's first step was watched by 600 million people — a fifth of humanity at the time."
    ),
    SpaceMission(
        id: "apollo13",
        name: "Apollo 13",
        year: 1970,
        agency: "NASA",
        destination: "Moon",
        description: "An oxygen tank explosion crippled the spacecraft 56 hours into the mission. The crew survived by using the lunar module as a lifeboat — NASA's finest hour of problem-solving."
    ),
    SpaceMission(
        id: "skylab",
        name: "Skylab",
        year: 1973,
        agency: "NASA",
        destination: "Earth Orbit",
        description: "America's first space station hosted three crews for a total of 171 days. Skylab proved humans could live and work in space long-term and conducted solar observations."
    ),
    SpaceMission(
        id: "apollo_soyuz",
        name: "Apollo-Soyuz",
        year: 1975,
        agency: "NASA / USSR",
        destination: "Earth Orbit",
        description: "The first joint US-Soviet space mission. An Apollo capsule docked with a Soyuz spacecraft, symbolizing détente and future international cooperation in space."
    ),
    SpaceMission(
        id: "voyager1",
        name: "Voyager 1",
        year: 1977,
        agency: "NASA",
        destination: "Outer Solar System",
        description: "Launched in 1977, Voyager 1 is the most distant human-made object, now in interstellar space. It carries a Golden Record with sounds and images of Earth for any extraterrestrials."
    ),
    SpaceMission(
        id: "voyager2",
        name: "Voyager 2",
        year: 1977,
        agency: "NASA",
        destination: "Outer Solar System",
        description: "The only spacecraft to visit all four giant planets — Jupiter, Saturn, Uranus and Neptune. Its Neptune flyby in 1989 revealed geysers on Triton and discovered six new moons."
    ),
    SpaceMission(
        id: "sts1",
        name: "STS-1 Columbia",
        year: 1981,
        agency: "NASA",
        destination: "Earth Orbit",
        description: "The first Space Shuttle mission. Columbia launched on April 12, 1981 — exactly 20 years after Gagarin — and landed like an airplane, pioneering reusable spaceflight."
    ),
    SpaceMission(
        id: "hubble",
        name: "Hubble Space Telescope",
        year: 1990,
        agency: "NASA / ESA",
        destination: "Earth Orbit",
        description: "Deployed from Space Shuttle Discovery, Hubble has transformed our understanding of the universe — measuring the expansion rate, revealing deep-field galaxies, and imaging nebulae in stunning detail."
    ),
    SpaceMission(
        id: "pathfinder",
        name: "Mars Pathfinder",
        year: 1997,
        agency: "NASA",
        destination: "Mars",
        description: "The first Mars rover, Sojourner, explored the Ares Vallis flood plain. The airbag landing system was revolutionary and the mission returned over 16,500 images of the Martian surface."
    ),
    SpaceMission(
        id: "iss_zarya",
        name: "ISS Assembly (Zarya)",
        year: 1998,
        agency: "NASA / RSA",
        destination: "Earth Orbit",
        description: "The Russian Zarya control module was the first ISS component, launched on November 20, 1998. Unity followed weeks later — beginning humanity's permanent home in orbit."
    ),
    SpaceMission(
        id: "mars_odyssey",
        name: "Mars Odyssey",
        year: 2001,
        agency: "NASA",
        destination: "Mars",
        description: "Detected vast hydrogen deposits near Mars's poles, confirming subsurface water ice. Mars Odyssey also serves as a communication relay for rovers on the surface."
    ),
    SpaceMission(
        id: "columbia_sts107",
        name: "Columbia STS-107",
        year: 2003,
        agency: "NASA",
        destination: "Earth Orbit",
        description: "Space Shuttle Columbia disintegrated on re-entry on February 1, 2003, due to foam damage during launch. All seven crew members were lost — a tragedy that reshaped NASA's safety culture.",
    ),
    SpaceMission(
        id: "spirit_opportunity",
        name: "Spirit & Opportunity",
        year: 2004,
        agency: "NASA",
        destination: "Mars",
        description: "Designed for 90-day missions, Spirit lasted 6 years and Opportunity ran for 14 years. Opportunity drove over 45 km across Mars, finding compelling evidence of past liquid water."
    ),
    SpaceMission(
        id: "new_horizons",
        name: "New Horizons",
        year: 2006,
        agency: "NASA",
        destination: "Pluto & Kuiper Belt",
        description: "The fastest spacecraft ever launched, New Horizons gave humanity its first close-up look at Pluto in 2015 — revealing heart-shaped nitrogen plains, mountains of ice, and a hazy atmosphere."
    ),
    SpaceMission(
        id: "phoenix",
        name: "Phoenix Mars Lander",
        year: 2008,
        agency: "NASA",
        destination: "Mars",
        description: "Landed near the Martian north pole and directly confirmed the presence of water ice just below the surface. Its robotic arm dug trenches and sampled Martian soil for chemistry analysis."
    ),
    SpaceMission(
        id: "curiosity",
        name: "Curiosity Rover",
        year: 2012,
        agency: "NASA",
        destination: "Mars",
        description: "The car-sized nuclear-powered rover landed using the remarkable 'sky crane' system. Curiosity confirmed Mars once had conditions suitable for microbial life in Gale Crater."
    ),
    SpaceMission(
        id: "maven",
        name: "MAVEN",
        year: 2013,
        agency: "NASA",
        destination: "Mars",
        description: "The Mars Atmosphere and Volatile Evolution mission revealed how Mars lost most of its atmosphere to solar wind — explaining the transition from a warm, wet world to today's frozen desert."
    ),
    SpaceMission(
        id: "chandrayaan2",
        name: "Chandrayaan-2",
        year: 2019,
        agency: "ISRO",
        destination: "Moon",
        description: "India's second lunar mission. The orbiter continues mapping the Moon, while the Vikram lander's hard landing near the south pole inspired Chandrayaan-3. India demonstrated formidable deep-space capability."
    ),
    SpaceMission(
        id: "osiris_rex",
        name: "OSIRIS-REx",
        year: 2016,
        agency: "NASA",
        destination: "Asteroid Bennu",
        description: "Collected a 60-gram sample from asteroid Bennu and returned it to Earth in 2023. It's the largest asteroid sample ever brought back and could reveal secrets about the early solar system."
    ),
    SpaceMission(
        id: "parker_solar",
        name: "Parker Solar Probe",
        year: 2018,
        agency: "NASA",
        destination: "Sun",
        description: "The fastest human-made object ever, Parker has 'touched the Sun' — flying through the corona at speeds exceeding 690,000 km/h. It is studying solar wind and the Sun's magnetic field up close."
    ),
    SpaceMission(
        id: "crew_dragon_dm2",
        name: "Crew Dragon Demo-2",
        year: 2020,
        agency: "NASA / SpaceX",
        destination: "ISS",
        description: "The first crewed orbital flight by a private spacecraft. Bob Behnken and Doug Hurley launched to the ISS aboard SpaceX Crew Dragon, ending a 9-year gap in US human spaceflight."
    ),
    SpaceMission(
        id: "change5",
        name: "Chang'e 5",
        year: 2020,
        agency: "CNSA",
        destination: "Moon",
        description: "China returned 1.73 kg of lunar samples to Earth — the first such sample return in 44 years. The mission proved China's complete deep-space round-trip capability."
    ),
    SpaceMission(
        id: "perseverance",
        name: "Perseverance & Ingenuity",
        year: 2021,
        agency: "NASA",
        destination: "Mars",
        description: "Perseverance is collecting rock cores for eventual return to Earth. It also carried Ingenuity, the first powered aircraft on another planet — a helicopter that completed over 70 flights on Mars."
    ),
    SpaceMission(
        id: "jwst",
        name: "James Webb Space Telescope",
        year: 2021,
        agency: "NASA / ESA / CSA",
        destination: "L2 Point",
        description: "The largest, most powerful telescope ever launched. JWST peers back 13.6 billion years to the dawn of the cosmos, images exoplanet atmospheres, and has already rewritten our understanding of the early universe."
    ),
    SpaceMission(
        id: "artemis1",
        name: "Artemis I",
        year: 2022,
        agency: "NASA",
        destination: "Moon",
        description: "The first flight of NASA's Space Launch System — humanity's most powerful rocket. The uncrewed Orion capsule flew beyond the Moon and splashed down safely, paving the way for astronaut lunar return.",
    ),
    SpaceMission(
        id: "chandrayaan3",
        name: "Chandrayaan-3",
        year: 2023,
        agency: "ISRO",
        destination: "Moon",
        description: "India landed Vikram and Pragyan near the lunar south pole — making India only the fourth country to soft-land on the Moon and the first to reach the south pole. Pragyan confirmed the presence of sulfur."
    ),
    SpaceMission(
        id: "artemis2",
        name: "Artemis II",
        year: 2024,
        agency: "NASA / CSA",
        destination: "Moon",
        description: "The first crewed Artemis flight will carry four astronauts — including the first woman and first person of colour to fly to lunar distance. The crew will loop around the Moon without landing."
    ),
]
