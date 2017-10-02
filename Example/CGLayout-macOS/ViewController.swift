//
//  ViewController.swift
//  CGLayout-macOS
//
//  Created by Denis Koryttsev on 02/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import CGLayout

class ColoredView: NSView {
    var backgroundColor: NSColor? {
        didSet { setNeedsDisplay(bounds) }
    }

    override var wantsUpdateLayer: Bool { return true }

    override func updateLayer() {
        super.updateLayer()
        layer?.backgroundColor = backgroundColor?.cgColor;
    }
}

class ViewController: NSViewController {
    var subviews: [ColoredView] = []
    let pulledView = ColoredView()
    let centeredView = ColoredView()
    let navigationBarBackView = ColoredView()
    let subview = ColoredView()

    lazy var stackScheme: StackLayoutScheme = { [unowned self] in
        var stack = StackLayoutScheme(items: self.subviews[0..<7])
        stack.axis = .vertical
        stack.direction = .toLeading
        stack.itemLayout = Layout(x: .left(215), y: .bottom(10), width: .boxed(235), height: .fixed(50))

        return stack
        }()
    lazy var latestItemLayout = Layout(vertical: (.top(10), .boxed(20)),
                                       horizontal: (.left(15), .fixed(30)))
    lazy var pulledLayout = Layout(x: .left(15), y: .top(10),
                                   width: .boxed(25), height: .boxed(20))
    lazy var bottomConstraint = LayoutAnchor.Bottom.limit(on: .inner)
    lazy var rightConstraint = LayoutAnchor.Right.limit(on: .outer)

//    lazy var labelPlaceholder: LabelPlaceholder = LabelPlaceholder(font: .systemFont(ofSize: 24), textColor: .red)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true

        subviews = (0..<10).map { i -> ColoredView in
            let view = ColoredView()
            view.backgroundColor = NSColor(white: (1 - (1 / max(0.5,CGFloat(i)))), alpha: 1 / max(0.5,CGFloat(i)))
            return view
        }
        subviews.forEach(view.addSubview)
        view.addSubview(pulledView)
        pulledView.backgroundColor = .red
        view.addSubview(centeredView)
        centeredView.backgroundColor = .yellow
        view.addSubview(navigationBarBackView)
        navigationBarBackView.backgroundColor = .black
        subview.backgroundColor = .red
        pulledView.addSubview(subview)

//        view.add(layoutGuide: labelPlaceholder)
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        //        var preview: UIView?
        let constrainedRect = CGRect(origin: .zero, size: CGSize(width: 200, height: 0))
        //        subviews[0..<7].forEach { subview in
        //            let constraints: [ConstrainRect] = preview.map { [($0.frame, bottomConstraint), (constrainedRect, rightConstraint)] } ?? []
        //            itemLayout.apply(for: subview, use: constraints)
        //            preview = subview
        //        }
        stackScheme.layout()
        var preview = stackScheme.items.last
        let lastPreview = stackScheme.items.last
        subviews[7..<10].forEach { subview in
            let constraints: [ConstrainRect] = [(lastPreview!.frame, bottomConstraint), (constrainedRect, rightConstraint)]
            let constraint: [ConstrainRect] = preview === lastPreview ? [] : [(preview!.frame, rightConstraint)]
            latestItemLayout.apply(for: subview, use: constraints + constraint)
            preview = subview
        }

        
        let topConstraint: LayoutAnchor.Top = true ? .pull(from: .outer) : .limit(on: .outer)

//        labelPlaceholder.layoutBlock(with: Layout(x: .right(), y: .top(), width: .scaled(0.6), height: .fixed(100)), constraints: [(topLayoutGuide as! UIView).layoutConstraint(for: [LayoutAnchor.Bottom.align(by: .outer)])]).layout()

        pulledLayout.apply(for: pulledView, use: [(subviews[1].frame, LayoutAnchor.Left.limit(on: .outer)), (subviews.first!.frame, topConstraint)])

        let centeredViewLayout = centeredView.layoutBlock(with: Layout(x: .center(), y: .center(), width: .fixed(20), height: .fixed(30)),
                                                          constraints: [subviews[7].layoutConstraint(for: [LayoutAnchor.equal])])

        // layout using only constraints and constrain to view (UINavigationController.view) from other hierarchy space.
//        navigationBarBackView.layoutBlock(with: Layout.equal, constraints: [navigationController!.navigationBar.layoutConstraint(for: [LayoutAnchor.equal])]).layout()

        let subviewLayout = subview.layoutBlock(with: Layout(x: .center(), y: .center(), width: .fixed(50), height: .fixed(1)),
                                                constraints: [centeredView.layoutConstraint(for: [LayoutAnchor.equal])])
        let subviewScheme = LayoutScheme(blocks: [centeredViewLayout, subviewLayout])
        let snapshotSubview = subviewScheme.snapshot(for: view.bounds)
        subviewScheme.apply(snapshot: snapshotSubview)
    }

    override func viewWillTransition(to newSize: NSSize) {
        super.viewWillTransition(to: newSize)
//        labelPlaceholder.view.text = "Placeholder label"
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

