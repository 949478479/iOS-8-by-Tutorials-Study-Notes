/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation

class RWTCountry: NSObject {
  var countryName: String = ""
  var imageName: String = ""
  var population: String = ""
  var currency: String = ""
  var language: String = ""
  var fact: String = ""
  var quizQuestion: String = ""
  var correctAnswer: String = ""
  var quizAnswers: [String] = []
  
  
  class func countries() ->NSArray {
    let plistFile =
    NSBundle.mainBundle().pathForResource("CountryData",
    ofType: "plist")
    let plistArray = NSArray(contentsOfFile: plistFile!)
    
    let countryArray = NSMutableArray()
    
    for dictionary in plistArray! {
    let country = RWTCountry();
    country.countryName = dictionary["countryName"] as! String
    country.imageName = dictionary["imageName"] as! String
    country.population = dictionary["population"]as! String
    country.currency = dictionary["currency"]as! String
    country.language = dictionary["language"]as! String
    country.fact = dictionary["fact"]as! String
    country.quizQuestion = dictionary["quizQuestion"]
   as! String
    country.correctAnswer = dictionary["correctAnswer"]
   as! String
    country.quizAnswers = dictionary["quizAnswers"] as! Array
    
    countryArray.addObject(country)
    }
    
    return NSArray(array: countryArray)
  }

}