import ArgumentParser
import Crypto
import Foundation
import CommonCrypto

extension String {

    func hmac(key: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), key, key.count, self, self.count, &digest)
        let data = Data(digest)
        return data.map { String(format: "%02hhx", $0) }.joined()
    }

}
struct IndicoFetcher: ParsableCommand {
    @Option(help: "API Key to Use")
    var apiKey: String

    @Option(help: "The API Secret")
    var apiSecret: String

    @Option(help: "The endpoint to connect to")
    var endpoint = "https://indico.cern.ch"

    @Argument(help: "The path in indico")
    var path: String

    @Argument(help: "The options")
    var options = ""

    mutating func run() throws {
        let timestamp = Int(Date().timeIntervalSince1970)
        let url = String(format: "/export%@.json?ak=%@&timestamp=%d", path, apiKey, timestamp)
        let hmac = url.hmac(key: apiSecret)
        let result = String(format: "%@%@&signature=%@", endpoint, url, hmac)
        let sessUrl = URL(string: result)!
        let sema = DispatchSemaphore( value: 0 )

        let task = URLSession.shared.dataTask(with: sessUrl) { data, response, error in
          if error != nil || data == nil {
              print("Client error!")
              return
          }

          guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
              print("Server error!")
              return
          }

          guard let mime = response.mimeType, mime == "application/json" else {
              print("Wrong MIME type!")
              return
          }

          //do {
          //    let json = try JSONSerialization.jsonObject(with: data!, options: [])
          //    print(json)
          //} catch {
          //    print("JSON error: \(error.localizedDescription)")
          //}        

          do {
              guard let jsonObject = try JSONSerialization.jsonObject(with: data!) as? [String: Any] else {
                  print("Error: Cannot convert data to JSON object")
                  return
              }
              guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                  print("Error: Cannot convert JSON object to Pretty JSON data")
                  return
              }
              guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                  print("Error: Couldn't print JSON in String")
                  return
              }
              
              print(prettyPrintedJson)
          } catch {
              print("Error: Trying to convert JSON data to string")
              return
          }


          //print(data)
          //print(response)
          //print(error)
          // Do something...
          sema.signal()

        }
        task.resume()
        sema.wait()

    }
}

IndicoFetcher.main()
