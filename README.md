
# UpMate SDK for Swift

The UpMate SDK allows you to easily manage and display update prompts in your React Native app. With simple integration, you can ensure that your users are always up-to-date with the latest version of your app.



### Installing with Swift Package Manager (SPM)

To add the UpMate SDK to your Xcode project using Swift Package Manager (SPM), follow these steps:

1. Open your project in Xcode.
2. Go to `File` > `Add Packages...`.
3. In the search bar, enter the repository URL: `https://github.com/UpmateApp/upmate-swift-sdk`
4. Select the package and set the version rules according to your needs.
5. Click `Add Package` to integrate it into your project.


## Initialization
### [Get your access token now, for free!](https://upmate-app.web.app/)

Before using the SDK, initialize it with your API key:

```swift
let upmate = UpMate.init(apiKey: "your-api-key-here")
```

## Displaying Update Prompts

### `displayLastUpdateIfNeeded()`

Checks if an update prompt needs to be shown. Displays the prompt only if a new update is available and necessary based on your criteria.

Mainly it checks if showing an update is needed depending on the version of the user. It's only displayed once per user per version update.

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
