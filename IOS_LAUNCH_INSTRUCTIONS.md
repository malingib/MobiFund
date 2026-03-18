iOS Launch Screen - instructions for Mobifund

This repository uses a Flutter-managed iOS launch storyboard.

To match the Mobifund branding on iOS do one of the following:

Option A — Use an image asset (quick):
1. In Xcode open `Runner.xcworkspace` under `ios/`.
2. In the asset catalog (Assets.xcassets) add a new Image Set named `LaunchImage`.
3. Provide @1x/@2x/@3x PNG images sized appropriately (e.g., 2732x2732 at @3x, center with background color).
4. Open `Runner/Info.plist` and ensure `UILaunchImages` or `Launch Screen File` references the asset (or update the storyboard to use the image view).

Option B — Use the LaunchScreen.storyboard (recommended):
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Open `LaunchScreen.storyboard` in the Runner target.
3. Set the storyboard background color to the Mobiwave blue `#0A61D9`.
4. Add an `UIImageView` centered and set its image to the `mobifund_logo` image you add to Assets.xcassets.
5. Export PNGs for 1x/2x/3x and add them to Assets.xcassets (name the image `mobifund_logo`).
6. Build & run.

Notes:
- Flutter may generate a storyboard in `ios/Runner/LaunchScreen.storyboard`. Modifying it directly in Xcode is the usual approach.
- If you prefer static images, ensure the LaunchScreen storyboard uses an ImageView that points to the Asset catalog image.
- Keep the logo SVG in `assets/images` for in-app rendering; iOS native launch must use raster PNGs.
