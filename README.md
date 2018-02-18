# SwiftySmiteAPI
A framework to access the Smite API in an easy way

## Getting Started

Just add the 3 Files (SwiftySmiteAPI, SwiftyMD5 and SwiftyJSON) to your project. 
I know I could've omitted the MD5 and JSON files and said to get them from the original sources, but decided to include them for easier access for newer programmers

### Prerequisites

Since this is a Framework written in Swift and designed to be used in Applications written in Swift you'll need a Mac and XCode.

### Installing

You might need to add a PList so the app is allowed to use http connections.
Create an entry called "App Transport Security Settings" in the plist-file, under that add an entry for "Allow Arbitrary Loads" and set it to true. 

## Built With

* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) - A Framework used to parse JSON data
* [SwiftDigest](https://github.com/NikolaiRuhe/SwiftDigest) - Pure Swift implementation of the MD5 algorithm
SwiftDigest is called SwiftyMD5 because I liked to keep a similiar naming scheme

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Thanks to NikolaiRuhe, Ruoyu Fu and Pinglin Tang for providing awesome free and easy to use code
* Thanks to my friends in Discord who quietly endured me when I talked about writing this, lol
