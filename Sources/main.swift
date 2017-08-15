import Kitura
import Foundation
import SwiftyJSON
import KituraNet

let router = Router()
router.all( middleware: StaticFileServer())
router.post(middleware: BodyParser())
var parameters = [String:String]() //needed for API call to Watson
router.post("/translates") { request, res, next in

    let json = request.body?.asJSON
    let textToTranslate = json?["text"].string
    let targetLang = json?["target"].string
    let sourceLang = json?["source"].string

    parameters["source"] = sourceLang
    parameters["target"] = targetLang
    parameters["text"] = textToTranslate

    let postData = try! JSON(parameters).rawData()

    // create the request
    var options: [ClientRequest.Options] = [
        .schema("https://"),
        .method("POST"),
        .hostname("gateway.watsonplatform.net"),
        .path("/language-translator/api/v2/translate"),
        .username("64a3ecc4-182b-47e9-a659-c580a7b5ca02"),
        .password("AnnGIdp6kCU7")
    ]
    //add headers
    var headers = [String:String]()
    headers["Accept"] = "application/json"
    headers["Content-Type"] = "application/json"
    options.append(.headers(headers))

    let request = HTTP.request(options) { response in
        do {

            if let responseStr = try response?.readString() {
                var data = responseStr.data(using: .utf8)!
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                if let translation = json["translations"]  {
                    for index in 0...translation.count-1 {
                        let transObj = translation[index] as! [String : AnyObject]
                        let transStr = String(describing: transObj)
                        let tempStr = String(transStr.characters.dropLast(1))
                        let finalStr = String(tempStr.characters.dropFirst(16))
                        res.send(finalStr)
                    }
                }
            }
        } catch {
            print("Error \(error)") // error handling here
        }
    }
    request.write(from: postData) //needed to convert back into JSON
    request.end()

}
Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
