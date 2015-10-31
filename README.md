# WKWebView

iOS 8 推出了`WKWebView`，用于取代备受诟病的`UIWebView`。

这个新类的很多方法都与`UIWebView`的方法非常相似，用法基本相同，而且很多属性都支持 KVO。

- [新增功能](#新增功能)
- [注入 javascript 代码](#javascript injection)
- [原生代码与 javascript 代码通信](#communication)

## 新增功能

下面介绍一些非常好用的功能。

#### 估测网页加载进度

`WKWebView`提供了如下属性，可以估测网页加载进度，该值介于 0.0~1.0 之间，支持 KVO。

```swift
public var estimatedProgress: Double { get }
```

#### 前进后退

`WKWebView`在`UIWebView`的基础上，对页面的前进后退功能进一步完善，还可以支持手势操作。

```swift
public var allowsBackForwardNavigationGestures: Bool

public var backForwardList: WKBackForwardList { get }

public func goToBackForwardListItem(item: WKBackForwardListItem) -> WKNavigation?
```

#### WKWebViewConfiguration

`WKWebView`可以通过`WKWebViewConfiguration`对象进行一些高级配置。

```swift
@NSCopying public var configuration: WKWebViewConfiguration { get }
```

例如，下面两个属性提供了对 HTML5 视频的播放设置：

```swift
public var allowsInlineMediaPlayback: Bool
public var requiresUserActionForMediaPlayback: Bool
```

另外，有一个非常好的特性，可以通过下面这个属性对页面进行 javascript 代码注入：

```swift
public var userContentController: WKUserContentController
```

<a name="javascript injection"></a>
## 注入 javascript 代码

#### WKUserContentController

`WKUserContentController`提供了强大的 javascript 代码注入功能：

```swift
public var userScripts: [WKUserScript] { get }

public func addUserScript(userScript: WKUserScript)
    
public func removeAllUserScripts()
    
public func addScriptMessageHandler(scriptMessageHandler: WKScriptMessageHandler, name: String)
    
public func removeScriptMessageHandlerForName(name: String)
```

#### WKUserScript

可以通过`WKUserScript`的构造方法创建一个 javascript 脚本：

```swift
public init(source: String, injectionTime: WKUserScriptInjectionTime, forMainFrameOnly: Bool)
```

例如，可以用类似下面这样的代码创建`WKUserScript`对象去除页面广告：


```swift
let configuration = WKWebViewConfiguration()
let removeAdScript = WKUserScript(source: "document.getElementsByClassName('adsbygoogle')[0].remove();", 
	injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
configuration.userContentController.addUserScript(removeAdScript)
let webView = WKWebView(frame: CGRect(), configuration: configuration)
```

这样加载出来的就是去除广告后的页面了。

<a name="communication"></a>
## 原生代码与 javascript 代码通信

#### WKScriptMessageHandler

使用`WKWebView`，原生代码和 javascript 代码之间的通信将更为自然。

如上所述，`WKUserContentController`提供了下面这个方法，可以定义一个回调方法：

```swift
public func addScriptMessageHandler(scriptMessageHandler: WKScriptMessageHandler, name: String)
```

`WKScriptMessageHandler`是一个协议，声明了如下方法：

```swift
public func userContentController(userContentController: WKUserContentController, 
	didReceiveScriptMessage message: WKScriptMessage)
```

只需在 javascript 代码中，使用该格式定义回调：

```
webkit.messageHandlers.name.postMessage(messageBody);
```

然后使用`addScriptMessageHandler(_:name:)`方法注册对应的名字即可。

具体使用类似这样：

```swift
let configuration = WKWebViewConfiguration()
let userScript = WKUserScript(source: "javascript 代码...", 
	injectionTime: .AtDocumentEnd, forMainFrameOnly: true)
configuration.userContentController.addScriptMessageHandler(self, name: "sayHello")
let webView = WKWebView(frame: CGRect(), configuration: configuration)
```

网页中的 javascript 代码的核心部分类似这样：

```javascript
<script>
	function sayHello()
	{
		webkit.messageHandlers.sayHello.postMessage("Hello!~");
	}
</script>
```

然后`self`需实现协议方法：

```swift
func userContentController(userContentController: WKUserContentController,
	didReceiveScriptMessage message: WKScriptMessage) {
	print("message: \(message.body)") // 打印 Hello!~
}
```

其中核心代码就是`webkit.messageHandlers.sayHello.postMessage("Hello!~");`这句。

`sayHello`指定了原生代码中注册的名字，即`addScriptMessageHandler(self, name: "sayHello")`注册的。

`postMessage()`中可传入一些对象，可通过`WKScriptMessage`对象的`body`属性获取。

该属性支持类型有：`NSNumber`，`NSString`，`NSDate`，`NSArray`，`NSDictionary`，`NSNull`。
