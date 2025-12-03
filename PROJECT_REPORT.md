# Project Report: SmartTracker

## 1. Introduction & Objectives

### Introduction

SmartTracker is a cross-platform Flutter application designed to track a user's live location, capture images, and sync activity logs to a remote server. It provides a real-time view of activities on an embedded map and allows users to manage their activity history. The application also features offline storage for recent activities, ensuring a seamless user experience even without a network connection.

### Objectives

The primary objectives of the SmartTracker application are to:

*   Track the user’s live location using GPS and display it on a map.
*   Allow users to capture an image with the device camera and attach it to an activity.
*   Synchronize activity logs (location, image, timestamp) with a REST API backend.
*   Enable users to view, search, and delete their activity history.
*   Store the 5 most recent activities offline for quick access.
*   Implement a clean, scalable, and maintainable architecture.
*   Provide a responsive user interface suitable for both phones and tablets.

## 2. App Architecture

The application follows the principles of **Clean Architecture**, separating concerns into three distinct layers: `domain`, `data`, and `presentation`.

```
/lib
|-- data
|   |-- datasources (local, remote)
|   |-- models
|   `-- repositories
|-- domain
|   |-- entities
|   `-- repositories
`-- presentation
    |-- pages
    |-- providers
    `-- widgets
```

### Layers

*   **Domain Layer**: This is the core of the application. It contains the business logic and is independent of any other layer.
    *   `entities`: Defines the core business objects, such as `ActivityLog`.
    *   `repositories`: Defines the abstract contracts for data operations (e.g., `ActivityRepository`).

*   **Data Layer**: This layer is responsible for data retrieval and storage. It implements the repository contracts defined in the domain layer.
    *   `models`: Extends domain entities to include data-specific functionality like JSON serialization/deserialization (e.g., `ActivityLogModel`).
    *   `datasources`: Contains the sources for data, split into `remote` (for REST API communication using `http`) and `local` (for offline caching using `shared_preferences`).
    *   `repositories`: Implements the `ActivityRepository` interface, orchestrating data from local and remote data sources. It handles the logic for fetching data, caching it, and gracefully falling back to cached data when offline.

*   **Presentation Layer**: This layer is responsible for the UI and user interaction.
    *   `pages`: Contains the application screens/pages (e.g., `HomePage`).
    *   `widgets`: Contains reusable UI components.
    *   `providers`: Manages the application's state using the `provider` package. The `ActivityProvider` communicates with the domain layer's repositories to fetch and update data, and notifies the UI of any changes.

### Data Flow

1.  **UI Event**: A user action in a `Page` (e.g., pressing a "refresh" button) triggers a call to a method in the `ActivityProvider`.
2.  **State Management**: The `ActivityProvider` calls the appropriate method on the `ActivityRepository` implementation in the data layer.
3.  **Data Layer**: The `ActivityRepositoryImpl` decides where to fetch the data from—either the `ActivityRemoteDataSource` (API) or the `ActivityLocalDataSource` (cache).
4.  **Data Retrieval**: The data source retrieves the data (from the REST API or `SharedPreferences`).
5.  **Data Return**: The data flows back through the repository and provider.
6.  **UI Update**: The `ActivityProvider` notifies its listeners (the UI), which then rebuild to display the new data.

## 3. API Design + Endpoints

The application interacts with a REST API for CRUD (Create, Read, Update, Delete) operations on activity logs.

**Base URL:** `https://api.smarttracker.com` (Placeholder)

### Endpoints

| Method | Endpoint              | Description                      | Request Body           | Response                                |
|--------|-----------------------|----------------------------------|------------------------|-----------------------------------------|
| `POST` | `/activities`         | Adds a new activity log.         | `ActivityLogModel` JSON | `201 Created`                          |
| `GET`  | `/activities`         | Retrieves all activity logs.     | -                      | `200 OK` with a list of `ActivityLog`s |
| `GET`  | `/activities?q={query}` | Searches for activities.         | -                      | `200 OK` with a list of matching `ActivityLog`s |
| `DELETE`| `/activities/{id}`  | Deletes a specific activity log. | -                      | `200 OK`                                |

### `ActivityLogModel` JSON Structure

```json
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "imagePath": "/path/to/image.jpg",
  "timestamp": "2023-10-27T10:00:00.000Z"
}
```

## 4. Sensor Handling (GPS + Camera)

Integration with device sensors is crucial for the application's core functionality. The `geolocator` and `camera` packages are used for this purpose.

### GPS (`geolocator`)

*   **Functionality**: To get the user's current latitude and longitude.
*   **Implementation Plan**: A service will be created to encapsulate the `geolocator` logic. It will handle requesting permissions and listening for location updates. The location data will be passed to the `ActivityProvider` when a new activity is created.
*   **Permissions**: The following permissions must be added to `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    ```
    For iOS, corresponding keys need to be added to `ios/Runner/Info.plist`.

### Camera (`camera`)

*   **Functionality**: To allow users to capture an image to attach to an activity log.
*   **Implementation Plan**: A new screen will be created for the camera preview. When the user takes a picture, the image file path will be saved and associated with the new activity log.
*   **Permissions**: The following permission is needed for Android in `AndroidManifest.xml`:
    ```xml
    <uses-permission android:name="android.permission.CAMERA" />
    ```
    For iOS, camera usage descriptions must be added to `ios/Runner/Info.plist`.

## 5. Offline Storage Mechanism

To ensure a good user experience and provide quick access to recent data, the application implements an offline storage mechanism for the 5 most recent activities.

*   **Technology**: `shared_preferences` is used for its simplicity and efficiency in storing small amounts of key-value data.
*   **Implementation**: The `ActivityLocalDataSourceImpl` is responsible for this logic.
    *   **Caching**: When activities are successfully fetched from the remote API, the `ActivityRepositoryImpl` takes the first 5 activities and passes them to `ActivityLocalDataSource.cacheRecentActivities()`. This method serializes the list of `ActivityLogModel`s into a JSON string and saves it to `SharedPreferences` under the key `CACHED_RECENT_ACTIVITIES`.
    *   **Retrieval**: If the application fails to fetch data from the remote API (e.g., due to no network connection), the `ActivityRepositoryImpl` calls `ActivityLocalDataSource.getRecentActivities()`. This method retrieves the JSON string from `SharedPreferences`, deserializes it back into a list of `ActivityLogModel`s, and returns it to be displayed in the UI.

## 6. Testing Scenarios

To ensure the quality and reliability of the application, the following testing scenarios will be covered:

### API Testing

*   **Tool**: Postman or a similar API testing tool.
*   **Scenarios**:
    *   Verify that `POST /activities` successfully creates a new log and returns `201`.
    *   Verify that `GET /activities` returns a list of all logs.
    *   Verify that `GET /activities?q={query}` returns correctly filtered results.
    *   Verify that `DELETE /activities/{id}` successfully removes a log.
    *   Test for error cases (e.g., invalid request body, non-existent ID).

### Sensor Testing

*   **GPS**:
    *   Verify that the app correctly requests location permissions.
    *   Test that the app displays the correct live location on the map.
    *   Test behavior when location services are disabled.
*   **Camera**:
    *   Verify that the app correctly requests camera permissions.
    *   Test that the camera preview displays correctly.
    *   Test that an image is successfully captured and attached to an activity.

### Offline Mode Testing

*   Turn off the device's network connection.
*   Verify that the app loads and displays the 5 most recent activities from the cache.
*   Verify that the app shows an appropriate message or state when trying to perform network-dependent actions (like adding a new activity).
*   Turn the network back on and verify that the app syncs correctly.
