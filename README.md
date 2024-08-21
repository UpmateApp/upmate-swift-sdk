
# UpMate SDK for React Native (Expo)

The UpMate SDK allows you to easily manage and display update prompts in your React Native app. With simple integration, you can ensure that your users are always up-to-date with the latest version of your app.

## Installation

To install the UpMate SDK, use npm or yarn:

```bash
npm install upmate-sdk
```

or

```bash
yarn add upmate-sdk
```

## Initialization

Before using the SDK, initialize it with your API key:

```swift
let upmate = UpMate.init(apiKey: "your-api-key-here")
```

## Displaying Update Prompts

### `displayLastUpdateIfNeeded()`

Checks if an update prompt needs to be shown. Displays the prompt only if a new update is available and necessary based on your criteria.

```swift
upmate.displayLastUpdateIfNeeded()
```

### `displayLastUpdateAlways()`

Forces the update prompt to be displayed every time, regardless of whether an update is needed.

```swift
upmate.displayLastUpdateAlways()
```

## Example Usage

```swift
let upmate = UpMate.init(apiKey: "your-api-key-here")

// Conditionally show update prompt
upmate.displayLastUpdateIfNeeded()

// Force update prompt to be shown
upmate.displayLastUpdateAlways()
```

## Notes

- Replace `"your-api-key-here"` with your actual API key.
- These methods should be called at appropriate points in your app's lifecycle, such as during app launch or when the user navigates to a settings page.

## Contributing

If you would like to contribute to this project, please open an issue or submit a pull request on [GitHub](https://github.com/your-repo).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
