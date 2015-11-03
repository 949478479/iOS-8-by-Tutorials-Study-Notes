# Asynchronous And Performance Testing

## 异步测试

```swift
func test_async_fetchPlaces() {
	// 创建用于异步测试的 XCTestExpectation 实例.
	let expectation = expectationWithDescription("我是描述...") 
	// 测试某个异步方法.	myObject.doSomethingAsyncWithCompletion {
		// ...				// 异步任务完成后,标记测试完成.		expectation.fulfill();	}
	// 设置超时时间为 1s. 如果到达超时时间或者测试被标记完成,此闭包会被调用.	waitForExpectationsWithTimeout(1.0) { error in 		XCTAssertNil(error, "异步任务在超时前没有完成."); 	}
}```

## 性能测试```swiftfunc test_performance_myFunction() {
	measureBlock {		// 在这里执行要测试性能的方法.		myObject.myFunction()	}}```
被测试的方法会进行十次采样，可以点击灰色的提示查看，如下图所示：
![](./Screnshot/PerformanceResult1.png)
这些小蓝条表示相对平均时间的偏移，`Value`值具体反映了该次执行代码花费的时间。
点击`Set Baseline`按钮可将平均时间`Average`设置为基线时间`Baseline`，如下图所示：
![](./Screnshot/PerformanceResult2.png)
进一步点击`Edit`按钮还可以对`Baseline`和`Max STDDEV`（最大标准差）进行编辑，点击`Accept`按钮可将`Baseline`重置为`Average`：

![](./Screnshot/PerformanceResult2.png)

设置了`Baseline`后，再次执行测试时，就会将花费时间与之比较，结果会像下图这样：

更慢了 | 更快了
--- | ---
![](./Screnshot/better.png) | ![](./Screnshot/PerformanceResult2.png)

##

```swift
class Dummy {}

extension NSBundle {
    class func testBundle() -> NSBundle {
        // 此方法返回类所在的 farmwork 的 bundle, 由于 Dummy 定义在 Test Target, 因此会返回 Test Target 的 bundle.
        return NSBundle(forClass: Dummy.self)
    }
}
```