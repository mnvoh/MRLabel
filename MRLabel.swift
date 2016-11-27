//
//  MRLabel.swift
//  
//	Moveable and Resizable Label View
//
//	MIT License
//
//	Copyright (c) 2016, Milad Nozari
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

import UIKit

@IBDesignable
class MRLabel: UIView
{
	private var _text: String = "SampleText"
	private var _color: UIColor = UIColor.white
	private var _stroke: UIColor = UIColor.black
	private var _strokeWidth: CGFloat = 2.0
	private var _font: UIFont = UIFont(name: "Helvetica Neue", size: 18)!
	private var _widgetColor: UIColor = UIColor(red: 0, green: 0.5, blue: 1.0, alpha: 1.0)
	
	private var sizeHandleView: UIView!
	private var borderLayer: CAShapeLayer!
	
	/// Whether the user is currently resizing the view or not.
	private var isResizing: Bool = false
	
	private let TEXT_MARGIN: CGFloat = 5
	private let HANDLE_WIDTH: CGFloat = 20
	private let MIN_FRAME_WIDTH: CGFloat = 60
	private let MIN_FRAME_HEIGHT: CGFloat = 40
	
	@IBInspectable
	public var text: String
	{
		get {
			return _text
		}
		set(value) {
			_text = value
			setNeedsDisplay()
		}
	}
	
	@IBInspectable
	public var color: UIColor
	{
		get {
			return _color
		}
		set(value) {
			_color = value
			setNeedsDisplay()
		}
	}
	
	@IBInspectable
	public var stroke: UIColor
	{
		get {
			return _stroke
		}
		set(value) {
			_stroke = value
			setNeedsDisplay()
		}
	}
	
	@IBInspectable
	public var strokeWidth: CGFloat
	{
		get {
			return _strokeWidth
		}
		set(value) {
			_strokeWidth = value
			setNeedsDisplay()
		}
	}
	
	public var font: UIFont
	{
		get {
			return _font
		}
		set(value) {
			_font = value
			setNeedsDisplay()
		}
	}
	
	@IBInspectable
	public var widgetColor: UIColor
		{
		get {
			return _widgetColor
		}
		set(value) {
			_widgetColor = value
			setupSizeHandleView()
			setNeedsDisplay()
		}
	}
	
	
	override init(frame: CGRect)
	{
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder)
	{
		super.init(coder: aDecoder)
		setup()
	}
	
	func panHandler(_ sender: UIPanGestureRecognizer)
	{
		if sender.numberOfTouches <= 0 {
			return
		}
		let location = sender.location(ofTouch: 0, in: self)
		let translation = sender.translation(in: self)
		
		if location.x > frame.width - HANDLE_WIDTH * 2 && location.y > frame.height - HANDLE_WIDTH * 2 {
			/// resize the view
			if (frame.size.width > MIN_FRAME_WIDTH || translation.x > 0) && (frame.size.width < UIScreen.main.bounds.width - 20 || translation.x < 0) {
				sizeHandleView.center.x = sizeHandleView.center.x + translation.x
				frame.size.width += translation.x
			}
			
			if (frame.size.height > MIN_FRAME_HEIGHT && frame.size.height < UIScreen.main.bounds.height - 20) || translation.y > 0 {
				sizeHandleView.center.y = sizeHandleView.center.y + translation.y
				frame.size.height += translation.y
			}
			
			sender.setTranslation(CGPoint.zero, in: self)
			self.setNeedsDisplay()
		}
		else {
			/// move the view
			if !isResizing {
				center.x = center.x + translation.x
				center.y = center.y + translation.y
			}
			sender.setTranslation(CGPoint.zero, in: self)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		let touchLocation = touches.first?.location(in: self)
		if let tl = touchLocation {
			if tl.x > frame.width - HANDLE_WIDTH * 2 && tl.y > frame.height - HANDLE_WIDTH * 2 {
				isResizing = true
			}
			else {
				isResizing = false
			}
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
	{
		isResizing = false
	}
	
	private func setup()
	{
		isUserInteractionEnabled = true
		clipsToBounds = false
		setupSizeHandleView()
		
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panHandler(_:)))
		addGestureRecognizer(panGesture)
	}
	
	private func setupSizeHandleView()
	{
		if let sizeHandleView = sizeHandleView {
			sizeHandleView.removeFromSuperview()
		}
		
		let vFrame = CGRect(x: frame.size.width - HANDLE_WIDTH, y: frame.size.height - HANDLE_WIDTH,
		                    width: HANDLE_WIDTH, height: HANDLE_WIDTH)
		let sFrame = CGRect(x: 0, y: 0, width: HANDLE_WIDTH, height: HANDLE_WIDTH)
		let view = UIView(frame: sFrame)
		let circle = UIBezierPath(ovalIn: vFrame)
		let circleShape = CAShapeLayer()
		circleShape.path = circle.cgPath
		circleShape.fillColor = _widgetColor.cgColor
		view.layer.addSublayer(circleShape)
		
		sizeHandleView = view
		
		addSubview(sizeHandleView)
	}
	
	private func updateBorder(_ rect: CGRect)
	{
		let borderRect = CGRect(
			x: 0,
			y: 0,
			width: rect.width - HANDLE_WIDTH / 2,
			height: rect.height - HANDLE_WIDTH / 2
		)
		let border = UIBezierPath(roundedRect: borderRect, cornerRadius: 3)
		borderLayer = CAShapeLayer()
		borderLayer.path = border.cgPath
		borderLayer.strokeColor = widgetColor.cgColor
		borderLayer.lineDashPattern = [4,2]
		borderLayer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
	}
	
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect)
	{
		///Draw the bounding dashed border
		if let borderLayer = borderLayer {
			borderLayer.removeFromSuperlayer()
		}
		updateBorder(rect)
		self.layer.addSublayer(borderLayer)
		
		
		/// Draw the text
		let s: NSString = text as NSString
		
		let paraStyle = NSMutableParagraphStyle()
		paraStyle.lineSpacing = 0.0
		paraStyle.alignment = NSTextAlignment.center
		
		let attributes = [
			NSStrokeWidthAttributeName: _strokeWidth * -1,
			NSStrokeColorAttributeName: _stroke,
			NSForegroundColorAttributeName: _color,
			NSParagraphStyleAttributeName: paraStyle,
			NSObliquenessAttributeName: 0.0,
			NSFontAttributeName: _font
		] as [String : Any]
		
		let textRect = CGRect(
			x: TEXT_MARGIN,
			y: TEXT_MARGIN,
			width: rect.width - HANDLE_WIDTH - TEXT_MARGIN,
			height: rect.height - HANDLE_WIDTH / 2 - TEXT_MARGIN
		)
		
		s.draw(in: textRect, withAttributes: attributes)
		
		bringSubview(toFront: sizeHandleView)
    }
}
