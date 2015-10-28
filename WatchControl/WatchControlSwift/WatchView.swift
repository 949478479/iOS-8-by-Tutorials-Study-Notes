/*
* Copyright (c) 2015 Razeware LLC
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

import UIKit

@IBDesignable
class WatchView: UIView {

    // MARK: - 切换显示模式

    @IBInspectable var enableAnalogDesign: Bool = true {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)

            enableAnalogDesign ? setupAnalogClockIfNeed() : setupDigitalClockIfNeed()
            setAnalogClockHidden(!enableAnalogDesign)
            setDigitalClockHidden(enableAnalogDesign)
            proofreadCurrentTime()

            CATransaction.commit()
        }
    }

    @IBInspectable var enableClockSecondHand: Bool = true {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)

            if enableAnalogDesign {
                enableClockSecondHand ? setupSecondeHandLayerIfNeed() : setupRingLayerIfNeed()
                ringLayer?.hidden = enableClockSecondHand
                secondHandLayer?.hidden = !enableClockSecondHand
                proofreadCurrentTime()
            }

            CATransaction.commit()
        }
    }

    @IBInspectable var enableColorBackground: Bool = false {
        didSet {
            setupBackgroundImageLayerIfNeed()
            backgroundImageLayer?.hidden = enableColorBackground
            if !enableColorBackground {
                backgroundLayerColor = UIColor.darkGrayColor() // 作为边框颜色.
            }
        }
    }

    // MARK: - 背景图层

    @IBInspectable var backgroundLayerColor: UIColor = UIColor.darkGrayColor() {
        didSet { backgroundLayer?.fillColor = backgroundLayerColor.CGColor }
    }

    private var backgroundLayer: CAShapeLayer?

    // MARK: - 背景图片图层

    @IBInspectable var backgroundImage: UIImage? {
        didSet { backgroundImageLayer?.contents = backgroundImage?.CGImage }
    }

    private var backgroundImageLayer: CALayer?

    // MARK: - 环形进度条图层

    @IBInspectable var ringThickness: CGFloat = 1.0
    @IBInspectable var ringColor: UIColor = UIColor.redColor()

    private var ringLayer: CAShapeLayer?

    // MARK: - 时分秒指针图层

    @IBInspectable var secondHandColor: UIColor = UIColor.redColor()
    @IBInspectable var minuteHandColor: UIColor = UIColor.whiteColor()
    @IBInspectable var hourHandColor:   UIColor = UIColor.whiteColor()

    private var secondHandLayer: CAShapeLayer?
    private var minuteHandLayer: CAShapeLayer?
    private var hourHandLayer: CAShapeLayer?

    // MARK: - 数字显示图层

    private var hourMinuteSecondLayer: CATextLayer?
    private var ampmLayer: CATextLayer?
    private var weekdayLayer: CATextLayer?

    // MARK: - 时间处理

    var timeZone = NSTimeZone.localTimeZone().name {
        didSet {
            let currentTimeZone = NSTimeZone(name: timeZone)!
            dateFormatter.timeZone = currentTimeZone
            dateFormatter.calendar.timeZone = currentTimeZone
            proofreadCurrentTime()
        }
    }

    private var lastMinute = 0

    private var currentTimeComponents: (hour: Int, minute: Int, second: Int) {
        var hour = 0, minute = 0, second = 0
        dateFormatter.calendar.getHour(&hour,
            minute: &minute, second: &second, nanosecond: nil, fromDate: NSDate())
        return (hour, minute, second)
    }

    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "HH:mm:ss,a,EEEE"
        return dateFormatter
    }()

    private var timerDidStart = false
    private lazy var timer: dispatch_source_t = {
        let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue())
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0)
        dispatch_source_set_event_handler(timer) { [unowned self] in
            if self.enableAnalogDesign {
                self.enableClockSecondHand ? self.animateHandClock() : self.animateRingClock()
            } else {
                self.animateDigitalClock()
            }
        }
        return timer
    }()

    // MARK: - 安装表盘

    private var didSetupClockFace = false
    override func layoutSubviews() {
        super.layoutSubviews()

        if didSetupClockFace { return }
        didSetupClockFace = true
        
        setupClockFace()
        proofreadCurrentTime()
        dispatch_resume(timer)
    }
}

// MARK: - Private
private extension WatchView {

    // MARK: - 背景&背景图片图层

    func setupClockFace() {
        setupBackgroundLayerIfNeed()
        enableColorBackground ? () : setupBackgroundImageLayerIfNeed()
        enableAnalogDesign ? setupAnalogClockIfNeed() : setupDigitalClockIfNeed()
    }

    func setupBackgroundLayerIfNeed() {
        if backgroundLayer != nil { return }
        layer.insertSublayer({
            backgroundLayer = CAShapeLayer()
            backgroundLayer!.frame     = bounds
            backgroundLayer!.fillColor = backgroundLayerColor.CGColor
            backgroundLayer!.path = {
                let rect  = bounds.insetBy(dx: 0.5, dy: 0.5) // 线条宽度一半.
                return UIBezierPath(ovalInRect: rect).CGPath
            }()
            return backgroundLayer!
        }(), atIndex: 0)
    }

    func setupBackgroundImageLayerIfNeed() {
        if backgroundImageLayer != nil { return }
        backgroundLayer?.addSublayer({
            backgroundImageLayer = CALayer()
            backgroundImageLayer!.frame = bounds
            backgroundImageLayer!.contents = backgroundImage?.CGImage
            backgroundImageLayer!.contentsGravity = kCAGravityResizeAspectFill
            backgroundImageLayer!.mask = {
                let maskLayer = CAShapeLayer()
                maskLayer.path = {
                    let inset       = ringThickness
                    let insetBounds = bounds.insetBy(dx: inset, dy: inset)
                    return UIBezierPath(ovalInRect: insetBounds).CGPath
                }()
                return maskLayer
            }()
            return backgroundImageLayer!
        }())
    }

    // MARK: - 指针显示表盘

    func setupAnalogClockIfNeed() {

        if hourHandLayer == nil {
            hourHandLayer = createClockHand(anchorPoint: CGPoint(x: 0.5, y: 1),
                handLength: 52, handWidth: 6, handAlpha: 1, handColor: hourHandColor)
            layer.addSublayer(hourHandLayer!)
        }

        if minuteHandLayer == nil {
            minuteHandLayer = createClockHand(anchorPoint: CGPoint(x: 0.5, y: 1),
                handLength: 26, handWidth: 6, handAlpha: 1, handColor: minuteHandColor)
            layer.addSublayer(minuteHandLayer!)
        }

        enableClockSecondHand ? setupSecondeHandLayerIfNeed() : setupRingLayerIfNeed()
    }

    func setupRingLayerIfNeed() {
        if ringLayer != nil { return }
        layer.addSublayer({
            ringLayer = CAShapeLayer()
            ringLayer!.frame       = bounds
            ringLayer!.fillColor   = nil
            ringLayer!.lineWidth   = ringThickness
            ringLayer!.strokeColor = ringColor.CGColor
            ringLayer!.transform   = CATransform3DMakeRotation(CGFloat(-M_PI_2), 0, 0, 1)
            ringLayer!.path = {
                let inset = ringThickness / 2
                let rect  = bounds.insetBy(dx: inset, dy: inset)
                return UIBezierPath(ovalInRect: rect).CGPath
            }()
            return ringLayer!
        }())
    }

    func setupSecondeHandLayerIfNeed() {
        if secondHandLayer != nil { return }
        secondHandLayer = createClockHand(anchorPoint: CGPoint(x: 0.5, y: 1),
            handLength: 20, handWidth: 3, handAlpha: 1, handColor: secondHandColor)
        layer.addSublayer(secondHandLayer!)
    }

    func setAnalogClockHidden(hidden: Bool) {
        hourHandLayer?.hidden = hidden
        minuteHandLayer?.hidden = hidden

        if hidden {
            ringLayer?.hidden = true
            secondHandLayer?.hidden = true
        } else {
            ringLayer?.hidden = enableClockSecondHand
            secondHandLayer?.hidden = !enableClockSecondHand
        }
    }

    // MARK: - 数字显示表盘

    func setupDigitalClockIfNeed() {

        if hourMinuteSecondLayer == nil {
            hourMinuteSecondLayer = createTextLayer("00:00:00",
                fontSize: bounds.height / 9, offset: bounds.height * 3 / 10) // 这些系数是微调出来的.
            layer.addSublayer(hourMinuteSecondLayer!)
        }

        if ampmLayer == nil {
            ampmLayer = createTextLayer("am", fontSize: bounds.height / 13,
                offset: bounds.height * 4.1 / 10, alignmentMode: kCAAlignmentCenter)
            layer.addSublayer(ampmLayer!)
        }

        if weekdayLayer == nil {
            // Wednesday 是七个表示星期的单词中最长的,因此用它来计算宽度.
            weekdayLayer = createTextLayer("Wednesday", fontSize: bounds.height / 13,
                offset: bounds.height * 7.5 / 10, alignmentMode: kCAAlignmentCenter)
            layer.addSublayer(weekdayLayer!)
        }
    }

    func setDigitalClockHidden(hidden: Bool) {
        ampmLayer?.hidden = hidden
        weekdayLayer?.hidden = hidden
        hourMinuteSecondLayer?.hidden = hidden
    }

    // MARK: - 动画

    func proofreadCurrentTime() {
        if enableAnalogDesign {
            enableClockSecondHand ? animateHandClock() : animateRingClock()
        } else {
            animateDigitalClock()
        }
    }

    func animateHandClock() {

        let (hour, minute, second) = currentTimeComponents

        if lastMinute != minute {
            lastMinute = minute
            let hourHandRotation = (CGFloat(hour) + CGFloat(minute) / 60.0) / 12.0 *  CGFloat(M_PI * 2)
            hourHandLayer?.transform = CATransform3DMakeRotation(hourHandRotation, 0, 0, 1)
        }

        let minuteHandRotation = (CGFloat(minute) + CGFloat(second) / 60.0) / 60.0 * CGFloat(M_PI * 2)
        minuteHandLayer?.transform = CATransform3DMakeRotation(minuteHandRotation, 0, 0, 1)

        let secondHandRotation = CGFloat(second) / 60.0 * CGFloat(M_PI * 2)
        secondHandLayer?.transform = CATransform3DMakeRotation(secondHandRotation, 0, 0, 1)

        print("\(hour):\(minute):\(second)")
    }

    func animateRingClock() {

        let (hour, minute, second) = currentTimeComponents

        if lastMinute != minute {
            lastMinute = minute
            let hourHandRotation = (CGFloat(hour) + CGFloat(minute) / 60.0) / 12.0 *  CGFloat(M_PI * 2)
            hourHandLayer?.transform = CATransform3DMakeRotation(hourHandRotation, 0, 0, 1)
        }

        let minuteHandRotation = (CGFloat(minute) + CGFloat(second) / 60.0) / 60.0 * CGFloat(M_PI * 2)
        minuteHandLayer?.transform = CATransform3DMakeRotation(minuteHandRotation, 0, 0, 1)

        // 第 0 秒即是第 60 秒,因此设置进度为 1, 进度条转满一整圈.
        let progress = (second == 0) ? 1.0 : CGFloat(second) / 60.0
        // 第 1 秒时,显示的是第 0 秒时的整圈进度条,设置起点为 1, 从而以顺时针方向清空进度条.
        // 隐式动画完成后恢复正常起点和终点.由于隐式动画默认只需 0.25 秒,因此有足够的时间在下一秒前完成该动画.
        if second == 1 {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.ringLayer?.strokeStart = 0.0
                self.ringLayer?.strokeEnd   = 0.0
            }
            ringLayer?.strokeStart = 1.0
            CATransaction.commit()
        } else {
            ringLayer?.strokeEnd = progress
        }

        print("\(hour):\(minute):\(second)")
    }

    func animateDigitalClock() {
        // "HH:mm:ss,a,EEEE"
        let dateStrings = dateFormatter.stringFromDate(NSDate()).componentsSeparatedByString(",")

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        ampmLayer?.string = dateStrings[1].lowercaseString
        weekdayLayer?.string = dateStrings[2]
        hourMinuteSecondLayer?.string = dateStrings[0]
        CATransaction.commit()

        print(hourMinuteSecondLayer!.string, ampmLayer!.string, weekdayLayer!.string)
    }

    // MARK: - 辅助方法

    func createClockHand(anchorPoint anchorPoint: CGPoint, handLength: CGFloat, handWidth: CGFloat,
        handAlpha: CGFloat, handColor: UIColor) -> CAShapeLayer {

            let handLayer = CAShapeLayer()

            handLayer.opacity     = Float(handAlpha)
            handLayer.lineWidth   = handWidth
            handLayer.anchorPoint = anchorPoint
            handLayer.lineCap     = kCALineCapRound
            handLayer.strokeColor = handColor.CGColor
            handLayer.path = {
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: 0.5, y: handLength))
                path.addLineToPoint(CGPoint(x: 0.5, y: bounds.midY))
                return path.CGPath
            }()
            handLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            handLayer.bounds   = CGRect(origin: CGPointZero, size: CGSize(width: 1, height: bounds.midY))

            return handLayer
    }

    func createTextLayer(string: String, fontSize: CGFloat, offset: CGFloat,
        alignmentMode: String = kCAAlignmentNatural) -> CATextLayer {

        let textLayer = CATextLayer()
        textLayer.string = string
        textLayer.fontSize = fontSize
        textLayer.alignmentMode = alignmentMode
        textLayer.contentsScale = UIScreen.mainScreen().scale
        textLayer.position = CGPoint(x: bounds.width / 2, y: offset)
        textLayer.bounds.size = (string as NSString)
            .sizeWithAttributes([NSFontAttributeName : UIFont(name: "Helvetica", size: fontSize)!])
        /*  00:00:00 这种时间格式下, 如果设置 kCAAlignmentCenter, 11 -> 12 会有个晃动.
            由于不同语言环境下表示 ampm 和星期几的字符长度不一,因此统一设置足够大的宽度,需要设置为 kCAAlignmentCenter.*/
        if alignmentMode == kCAAlignmentCenter {
            textLayer.bounds.size.width = bounds.width
        }

        return textLayer
    }
}
