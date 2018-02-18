//
//  SwiftySmiteAPI.swift
//  SwiftySmiteAPI
//
//  Created by Michael Brünen on 17.02.18.
//  Copyright © 2018 Michael Brünen. All rights reserved.
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

// Important Notes:
// Functions will return "nil" when there is nothing to get (e.g. a hidden profile) or there is no connection


public class SwiftySmiteAPI {
    // MARK: - Properties
    private let devID: String
    private let authKey: String
    private let platformURL: baseURL
    private let responseFormat: ResponseFormat
    private var sessionID: String
    public enum APIError: Error{
        case invalidDevOrAuth
    }
    public enum baseURL: String {
        case SmitePC = "http://api.smitegame.com/smiteapi.svc"
        case SmiteXbox = "http://api.xbox.smitegame.com/smiteapi.svc"
        case SmitePS4 = "http://api.ps4.smitegame.com/smiteapi.svc"
    }
    public enum ResponseFormat: String {
        case json = "json"
        case xml = "xml"
    }
    public enum gameMode: String {
        case Arena = "435"
        case Assault = "445"
        case Clash = "466"
        case Siege = "459"
        case Conquest = "426"
        case ConquestRanked = "451"
        case Joust = "448"
        case JoustRanked = "450"
        case DuelRanked = "440"
        case MOTD = "434"
    }
    public enum languageCode: String {
        case English = "1"
        case German = "2"
        case French = "3"
        case Chinese = "5"
        case Spanish = "7"
        case SpanishLatinAmerica = "9"
        case Portuguese = "10"
        case Russian = "11"
        case Polish = "12"
        case Turkish = "13"
    }
    public enum leagueTier: String {
        case BronzeV = "1"
        case BronzeIV = "2"
        case BronzeIII = "3"
        case BronzeII = "4"
        case BronzeI = "5"
        case SilverV = "6"
        case SilverIV = "7"
        case SilverIII = "8"
        case SilverII = "9"
        case SilverI = "10"
        case GoldV = "11"
        case GoldIV = "12"
        case GoldIII = "13"
        case GoldII = "14"
        case GoldI = "15"
        case PlatinumV = "16"
        case PlatinumIV = "17"
        case PlatinumIII = "18"
        case PlatinumII = "19"
        case PlatinumI = "20"
        case DiamondV = "21"
        case DiamondIV = "22"
        case DiamondIII = "23"
        case DiamondII = "24"
        case DiamondI = "25"
        case MastersI = "26"
        case Grandmaster = "27"
    }

    
    // MARK: - Initializer
    public init(devID: String, authKey: String, platform platformURL: baseURL, format: ResponseFormat) {
        self.devID = devID
        self.authKey = authKey
        self.platformURL = platformURL
        self.responseFormat = format
        sessionID = "CREATE SESSION FIRST"
    }
    

    // MARK: - Helping functions like creating TimeStamps, MD5Hashes and URLs to call
    private func createCurrentTimeStamp() -> String {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyyMMddHHmmss"
        return df.string(from: Date())
    }
    private func createMD5(methodToCall: String) -> String{
        //create signature to hash
        let signature = devID + methodToCall + authKey + createCurrentTimeStamp()
        //then return the hashed signature as a string
        return signature.utf8.md5.rawValue
    }
    /// Function to create call urls for the Smite API
    ///
    /// - Parameter APICall: The name of the api call to make (e.g. "testsession")
    /// - Returns: An URL that can be used to make calls to the Smite API
    public func createCallURL(APICall: String) -> URL? {
        //Aside from createSession every other api call uses the same format
        //platformURL/{APICall}[ResponseFormat]/{developerId}/{signature}/{session}/{timestamp}
        let urlString = "\(platformURL.rawValue)/" +
                        "\(APICall)\(responseFormat)/" +
                        "\(devID)/" +
                        "\(createMD5(methodToCall: APICall))/" +
                        "\(sessionID)/" +
                        "\(createCurrentTimeStamp())"
        if let url = URL(string: urlString) {
            return url
        } else {
            print("ERROR: URL creation failed")
            return nil
        }
    }
    /// Function to create calls that require additional data, e.g. Playername, Match-ID etc
    ///
    /// - Parameters:
    ///   - APICall: The name of the api call to make (e.g. "testsession")
    ///   - additional: Additional information, like Playername, Match-ID etc
    /// - Returns: An URL that can be used to make calls to the Smite API
    public func createCallURL(APICall: String, additional: String) -> URL? {
        //for those calls that have additional characters at the end of the URL
        if let url = createCallURL(APICall: APICall) {
            return url.appendingPathComponent(additional)
        } else {
            return nil
        }
    }
    
    
    // MARK: - Functions to create and test sessions
    

    /// A required step to Authenticate the developerId/signature for further API use.
    /// This functions needs to be called before making any calls.
    ///
    /// - Throws: Will throw an error when provided invalid dev-id or auth-key
    public func createSession() throws {
        //create the string for the url to call
        let urlString = "\(platformURL.rawValue)/" +
            "createsession\(ResponseFormat.json)/" +
            "\(devID)/" +
            "\(createMD5(methodToCall: "createsession"))/" +
            "\(createCurrentTimeStamp())"
        
        //make it into an URL
        if let url = URL(string: urlString) {
            if let data = try? String(contentsOf: url) {
                let json = JSON(parseJSON: data)
                if json["session_id"].stringValue != "" {
                    print("GOT SESSION ID:")
                    print("\(json["session_id"].stringValue)\n")
                    sessionID = json["session_id"].stringValue
                } else {
                    throw APIError.invalidDevOrAuth
                }
            }
        }
    }
    
    /// A means of validating that a session is established.
    /// It's recommended to use this before any calls you make to ensure an active session.
    ///
    /// - Returns: Boolean value showing if the current session is still active
    public func testsession() -> Bool {
        if let url = createCallURL(APICall: "testsession"){
            if let _ = try? String(contentsOf: url){
                //testsession doesn't return any meaningfull data
                return true
            }
        }
        return false
    }

    // MARK: - Function to make custom calls
    /// Function to make completely custom calls to the API.
    /// WARNING: Aside from the base-url everything else needs to be provided in the string.
    ///
    /// - Parameter withURL: the URL for the call. Can be created with "createCallURL"
    /// - Returns: A String containing JSON or XML data
    public func customCall(withURL url: URL) -> String? {
        return apiCall(withURL: url)
    }
    
    /// Function that actually makes the API calls
    /// Used for better clarity between calls made in this class/wrapper and outside calls (customCall)
    ///
    /// - Parameter withURL: the URL for the call. Can be created with "createCallURL"
    /// - Returns: A String containing JSON or XML data
    private func apiCall(withURL url: URL) -> String? {
        if let data = try? String(contentsOf: url) {
            return data
        }
        print("ERROR: Invalid URL or no data to fetch")
        return nil
    }
    
    // MARK: - Functions used to make calls to the SmiteAPI
    /// A quick way of validating access to the Hi­Rez API.
    ///
    /// - Returns: Boolean value showing if connectivity is given
    public func ping() -> Bool {
        let urlString = "\(platformURL.rawValue)/ping\(responseFormat)"
        if let url = URL(string: urlString) {
            if let _ = try? String(contentsOf: url){
                return true
            }
        }
        return false
    }

    /// Function returns UP/DOWN status for the primary game/platform environments. Data is cached once a minute.
    ///
    /// - Returns: Current server status as a String containing JSON or XML data
    public func getHirezServerStatus() -> String? {
        if let url = createCallURL(APICall: "gethirezserverstatus") {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns API Developer daily usage limits and the current status against those limits.
    ///
    /// - Returns: Current status as a String containing JSON or XML data
    public func getDataUsed() -> String? {
        if let url = createCallURL(APICall: "getdataused") {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns information regarding a particular match. Rarely used in lieu of getmatchdetails().
    ///
    /// - Parameter matchID: the match-id as a string
    /// - Returns: Information of a match as a String containing JSON or XML data
    /// Not public because it doesn't return data atm
    private func getModeDetails(matchID: String) -> String? {
        //function not implemented due to incorrect return data
        if let url = createCallURL(APICall: "getmodedetails"){
            let fullUrl = url.appendingPathComponent("/\(matchID)")
            print(fullUrl)
            if let data = try? String(contentsOf: fullUrl) {
                return data
            }
        }
        return nil
    }
    
    /// Returns the matchup information for each matchup for the current eSports Pro League season. An important return value is
    /// “match_status” which represents a match being scheduled (1), in­progress (2), or complete (3)
    ///
    /// - Returns: Matchup information as a String containing JSON or XML data
    public func getESportProLeagueDetails() -> String? {
        if let url = createCallURL(APICall: "getesportsproleaguedetails") {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns the Smite User names of each of the player’s friends.
    ///
    /// - Parameter playerName: The Player whose friends should be returned
    /// - Returns: The friends of the player as a String containing JSON or XML data
    public func getFriends(from playerName: String) -> String? {
        if let url = createCallURL(APICall: "getfriends", additional: playerName) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns the Rank and Worshippers value for each God a player has played.
    ///
    /// - Parameter playerName: The name of the player whose godranks should be returned
    /// - Returns: The godranks of the player as a String containing JSON or XML data
    public func getGodRanks(from playerName: String) -> String? {
        if let url = createCallURL(APICall: "getgodranks", additional: playerName) {
           return apiCall(withURL: url)
        }
        return nil
    }

    /// Returns all Gods and their various attributes.
    ///
    /// - Returns: Returns data of gods as a String containing JSON or XML data
    public func getGods(inLanguage code: languageCode) -> String? {
        if let url = createCallURL(APICall: "getgods", additional: code.rawValue) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns the current season’s leaderboard for a god/queue combination
    ///
    /// - Parameters:
    ///   - godID: The ID for the god as a String (use getGods to get IDs)
    ///   - queue: Only ranked queues
    /// - Returns: The current leaderboard for a god in the selected game-mode as a String containing JSON or XML data
    public func getGodLeaderBoard(godID: String, mode queue: gameMode) -> String? {
        if queue != gameMode.ConquestRanked && queue != gameMode.JoustRanked && queue != gameMode.DuelRanked { return nil }
        if let url = createCallURL(APICall: "getgodleaderboard", additional: "\(godID)/\(queue.rawValue)") {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns all available skins for a particular God.
    ///
    /// - Parameters:
    ///   - godID: The ID for the god as a String (use getGods to get IDs)
    ///   - code: The language code for the the desired language
    /// - Returns: All available skins for a god as a String containing JSON or XML data
    public func getGodSkins(godID: String, inLanguage code: languageCode) -> String? {
        if let url = createCallURL(APICall: "getgodskins", additional: "\(godID)/\(code.rawValue)") {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns the Recommended Items for a particular God.
    ///
    /// - Parameters:
    ///   - godID: The ID for the god as a String (use getGods to get IDs)
    ///   - code: The language code for the the desired language
    /// - Returns: The recommended items for all modes for a god as a String containing JSON or XML data
    public func getRecommendedItems(godID: String, inLanguage code: languageCode) -> String? {
        if let url = createCallURL(APICall: "getgodrecommendeditems", additional: "\(godID)/\(code.rawValue)") {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns all Items and their various attributes.
    ///
    /// - Parameter code: The language code for the the desired language
    /// - Returns: All items with their attributes as a String containing JSON or XML data
    public func getItems(inLanguage code: languageCode) -> String? {
        if let url = createCallURL(APICall: "getitems", additional: code.rawValue) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns the statistics for a particular completed match.
    ///
    /// - Parameter matchID: The ID for the match of which stats should be returned
    /// - Returns: The stats of the match as a String containing JSON or XML data
    public func getMatchDetails(matchID: String) -> String? {
        if let url = createCallURL(APICall: "getmatchdetails", additional: matchID) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns the statistics for a particular set of completed matches.
    /// NOTE: There is a byte imit to the amount of data returned; please limit the CSV parameter to 5 to 10 matches
    /// because of this and for Hi­Rez DB Performance reasons
    ///
    /// - Parameter matchIDArray: A String array containing match-ids
    /// - Returns: The stats of the matches as a String containing JSOn or XML data
    /// Not public because it doesn't return data atm
    private func getMatchDetailsBatch(matchIDArray: [String]) -> String? {
        //compose the variable for the additional data at the end of the api call
        var additional = ""
        for match in matchIDArray {
            additional += "\(match),"
        } //remove the last ','
        additional.remove(at: additional.index(before: additional.endIndex))

        if let url = createCallURL(APICall: "getmatchdetails", additional: additional) {
            print(url)
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns player information for a live match.
    /// Won't return meaningful data for past matches
    ///
    /// - Parameter matchID: The ID for the match of which stats should be returned
    /// - Returns: The player details for a live match as a String containing JSON or XML data
    public func getMatchPlayerDetails(matchID: String) -> String? {
        if let url = createCallURL(APICall: "getmatchplayerdetails", additional: matchID){
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Lists all Match IDs for a particular Match Queue; useful for API developers interested in constructing data by Queue.
    /// To limit the data returned, an hour parameter was added. For more info consult the API documentation
    ///
    /// - Parameters:
    ///   - queue: The gamemode for which the call will be made
    ///   - date: The date from which data should be returned. Format is: 'yyyyMMddHH'
    ///   - hour: The hour range from which data should be returned, valid values are '0' - '23'.
    ///     '-1' represents the whole day. To avoid HTTP timeouts specify a 10­ minute window within the specified hour field.
    ///     to lessen the size of data returned by appending a “,mm” value to the end of hour, e.g. '3,00'.
    ///     Only valid values for mm are “00”, “10”, “20”, “30”, “40”, “50”.
    /// - Returns: All match ids from a certain day in a certain time range as a String containing JSON or XML data
    public func getMatchIDsByQueue(mode queue: gameMode, date: String, hour: String) -> String? {
        let additional = "\(queue.rawValue)/\(date)/\(hour)"
        if let url = createCallURL(APICall: "getmatchidsbyqueue", additional: additional) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns the top players for a particular league (as indicated by the queue/tier/season parameters).
    ///
    /// - Parameters:
    ///   - queue: Only ranked queues
    ///   - tier: The tier of which data should be returned
    ///   - season: The season from which data should be returned
    /// - Returns: The Leaderboard of the selected mode, tier and season as a String containing JSON or XML data
    public func getLeagueLeaderboard(mode queue: gameMode, tier: leagueTier, season: String) -> String? {
        if queue != gameMode.ConquestRanked && queue != gameMode.JoustRanked && queue != gameMode.DuelRanked { return nil }
        let additional = "\(queue.rawValue)/\(tier.rawValue)/\(season)"
        if let url = createCallURL(APICall: "getleagueleaderboard", additional: additional) {
            print(url)
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Provides a list of seasons (including the single active season) for a match queue.
    ///
    /// - Parameter queue: The gamemode for which the call will be made
    /// - Returns: The list of seasons for a mode as a String containing JSON or XML data
    public func getLeagueSeasons(mode queue: gameMode) -> String? {
        if let url = createCallURL(APICall: "getleagueseasons", additional: queue.rawValue) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Gets recent matches and high level match statistics for a particular player.
    ///
    /// - Parameter player: The name of the player
    /// - Returns: Recent matches of a particular player as a String containing JSON or XML data
    public func getMatchHistory(for player: String) -> String? {
        if let url = createCallURL(APICall: "getmatchhistory", additional: player) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns information about the 20 most recent Match­of­the­Days.
    ///
    /// - Returns: Information about the last 20 MotDs as a String containing JSON or XML data
    public func getRecentMotDs() -> String? {
        if let url = createCallURL(APICall: "getmotd") {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns league and other high level data for a particular player.
    ///
    /// - Parameter playerName: The name of the player
    /// - Returns: League and other high level data for a particular player as a String containing JSON or XML data
    public func getPlayer(withName playerName: String) -> String? {
        if let url = createCallURL(APICall: "getplayer", additional: playerName) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns player status as follows: 0 = Offline, 1 = In Lobby, 2 = In God Selection, 3 = In Game, 4 = Online, 5 = Unknonw (not found)
    ///
    /// - Parameter playerName: The name of the player
    /// - Returns: The status of the player as a String containing JSON or XML data
    public func getPlayerStatus(from playerName: String) -> String? {
        if let url = createCallURL(APICall: "getplayerstatus", additional: playerName) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns match summary statistics for a (player, queue) combination grouped by gods played.
    ///
    /// - Parameters:
    ///   - playerName: The name of the player
    ///   - queue: The gamemode
    /// - Returns: match summary statistics for a player+queue combination as a String containing JSON or XML data
    public func getQueueStats(forPlayer playerName: String, mode queue: gameMode) -> String? {
        let additional = "\(playerName)/\(queue.rawValue)"
        if let url = createCallURL(APICall: "getqueuestats", additional: additional) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Lists the number of players and other high level details for a particular clan.
    ///
    /// - Parameter clanID: The ID of the clan
    /// - Returns: The number of players and other details of a particular clan as a String containing JSON or XML data
    public func getTeamDetails(clanID: String) -> String? {
        if let url = createCallURL(APICall: "getteamdetails", additional: clanID) {
            return apiCall(withURL: url)
        }
        return nil
    }

    /// Lists the players for a particular clan.
    ///
    /// - Parameter clanID: The ID of the clan
    /// - Returns: The players of the clan as a String containing JSON or XML data
    public func getTeamPlayers(clanID: String) -> String? {
        if let url = createCallURL(APICall: "getteamplayers", additional: clanID) {
            return apiCall(withURL: url)
        }
        return nil
    }

    /// Lists the 50 most watched / most recent recorded matches.
    ///
    /// - Returns: The 50 most watched/recent recorded matches as a String containing JSON or XML data
    public func getTopMatches() -> String? {
        if let url = createCallURL(APICall: "gettopmatches") {
            return apiCall(withURL: url)
        }
        return nil
    }

    /// Returns high level information for Team names containing the “teamName” string.
    ///
    /// - Parameter teamName: The name of the team to search for
    /// - Returns: High level information for the team names containing the search-string as a String containing JSON or XML data
    public func searchTeams(withName teamName: String) -> String? {
        if let url = createCallURL(APICall: "searchteams", additional: teamName) {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    /// Returns select achievement totals (Double kills, Tower Kills, First Bloods, etc) for the specified playerId.
    ///
    /// - Parameter playerID: The id of the player
    /// - Returns: Select achievment totals for the specified player as a String containing JSON or XML data
    public func getPlayerAchievments(forPlayerID playerID: String) -> String? {
        if let url = createCallURL(APICall: "getplayerachievements", additional: playerID) {
            return apiCall(withURL: url)
        }
        return nil
    }

    /// Function returns information about current deployed patch. Currently, this information only includes patch version.
    ///
    /// - Returns: Information about the current deployed patch as a String containing JSON or XML data
    public func getPatchInfo() -> String? {
        if let url = createCallURL(APICall: "getpatchinfo") {
            return apiCall(withURL: url)
        }
        return nil
    }
    
    
}
