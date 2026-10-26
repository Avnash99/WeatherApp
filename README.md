# Weather Activity Planner

A native iOS app that helps users explore the upcoming 7-day weather forecast for a city or town and assess how suitable each day may be for:

- Skiing
- Surfing
- Outdoor sightseeing
- Indoor sightseeing

Weather and location data are retrieved from the [Open-Meteo Geocoding API](https://open-meteo.com/en/docs/geocoding-api) and [Open-Meteo Forecast API](https://open-meteo.com/en/docs).

## Features

- Search for a city or town.
- Retrieve a seven-day weather forecast for the selected location.
- Rank daily conditions for the four supported activities.
- Present weather information and activity recommendations in a native iOS interface.

> Update this list to reflect the features implemented in the submitted app.

## Built With

- **Platform:** iOS
- **Language:** Swift
- **UI:** SwiftUI
- **Weather data:** Open-Meteo APIs
- **Architecture:** Add the architecture used by this project.
- **Testing:** Add the testing framework and tests implemented.

## APIs

### Geocoding

Used to search for a location and obtain its coordinates.

`https://geocoding-api.open-meteo.com/v1/search`

### Forecast

Used to retrieve weather forecast data for the selected coordinates.

`https://api.open-meteo.com/v1/forecast`

See the [Open-Meteo documentation](https://open-meteo.com/en/docs) for available forecast variables and request parameters.

## Activity Suitability

The app evaluates forecast data to estimate suitability for each activity. The factors may include:

| Activity | Potential factors |
| --- | --- |
| Skiing | Temperature, snowfall, and snow conditions |
| Surfing | Wind and wave conditions, when available |
| Outdoor sightseeing | Precipitation, temperature, and general weather |
| Indoor sightseeing | Whether outdoor conditions are unfavorable |

**Scoring method:** Document the actual scoring rules, thresholds, and weights implemented in this project. Do not treat the recommendations as a guarantee of safety or local conditions.

## Requirements

- A Mac with a compatible version of Xcode
- An iOS Simulator or compatible physical iOS device
- Internet access to call the Open-Meteo APIs

## Run Locally

1. Clone this repository:

   ```bash
   git clone <YOUR_GITHUB_REPOSITORY_URL>
   ```

2. Open the `.xcodeproj` or `.xcworkspace` file in Xcode, as applicable.
3. Select the app scheme and an iOS Simulator or connected device.
4. Build and run the app.

No backend is required for this exercise.

## Testing

Describe the tests available in this repository. Useful areas to cover include:

- Suitability scoring and ranking logic
- City search results and empty results
- Forecast response decoding
- Missing or unavailable weather data
- Network errors and loading states

## Assumptions and Limitations

- The app uses the seven-day forecast returned by the configured API request.
- Suitability depends on the forecast variables and scoring rules implemented.
- Forecasts can change and should be treated as estimates.
- General weather data may not fully capture local skiing or surfing safety conditions.
- Indoor sightseeing suitability is an estimate, not a statement about venue availability.
- No backend is required for this exercise.

Add any project-specific assumptions, known limitations, and trade-offs here.

## Engineering Decisions

Briefly explain the decisions made in this implementation, including:

- Why the selected architecture and state-management approach were chosen
- How networking and errors are handled
- How suitability rules are separated from the UI
- What was tested and how AI-assisted work was verified, if applicable

## License

Add a license if you intend to distribute this project under one.
