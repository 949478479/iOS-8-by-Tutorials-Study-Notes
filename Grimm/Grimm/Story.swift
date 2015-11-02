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

class Story: CustomDebugStringConvertible {
    let title: String
    let content: String

    init(title: String, content: String) {
        self.title = title
        self.content = content
    }

    var description: String {
        return title
    }

    var debugDescription: String {
        return title
    }

    class func loadStories(completion: ([Story]?, NSErrorPointer) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {

            let error   = NSErrorPointer()
            let path    = NSBundle.mainBundle().bundlePath
            let manager = NSFileManager.defaultManager()

            var stories = [Story]()

            do {
                let contents = try manager.contentsOfDirectoryAtPath(path)

                for file in contents {
                    guard file.hasSuffix(".grm") else { continue }

                    let filePath = (path as NSString).stringByAppendingPathComponent(file)
                    let title = (file as NSString).stringByDeletingPathExtension

                    do {
                        let content = try String(contentsOfFile: filePath)
                        let story = Story(title: title, content: content)
                        stories.append(story)
                    } catch let error1 as NSError {
                        error.memory = error1
                        break
                    }
                }
            } catch let error1 as NSError {
                error.memory = error1
            } catch {
                fatalError()
            }
            
            stories.sortInPlace { $0.title < $1.title }
            
            dispatch_async(dispatch_get_main_queue()) {
                error != nil ? completion(nil, error) : completion(stories, nil)
            }
        }
    }
}
