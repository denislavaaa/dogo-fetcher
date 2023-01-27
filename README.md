## What is Dogo Fetcher?
Dogo Fetcher is a lightweight library for fetching random dog images from [Dog.ceo](https://dog.ceo/)

## Requirements:
- iOS 13
## How to use 
- `getImage() -> UIImage` - returns a random dog image
- `getImages(count: Int) -> [UIImage]` - returns a predefined number of dog images [**50 is the API limit**]
### Gallery usage
You can use `DogoFetcher` as basic gallery functionality supporting indexing, previous and next.
- `getNextImage() -> UIImage` - Increments the gallery index; If the index was already fetched, the same image will be given; otherwise a new random image will be returned
- `getPreviousImage() -> UIImage` - Decrements the gallery index; Retrnes the previously fetched image for this index
- `resetGallery()` -> Reset the gallery index and caching mechanism.

### NOTE: 
The library uses SwiftConcurrency
Currently the caching mechanism used is the default stragtegy for URLSession.
