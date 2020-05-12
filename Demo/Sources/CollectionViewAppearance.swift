//
//  CollectionViewAppearance.swift
//  Demo
//
//  Created by Kyle Van Essen on 10/20/19.
//  Copyright © 2019 Kyle Van Essen. All rights reserved.
//

import Listable
import BlueprintLists
import BlueprintUI
import BlueprintUICommonControls


let demoAppearance = Appearance {
    $0.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
                
    $0.list.layout = .init(
        padding: UIEdgeInsets(top: 30.0, left: 20.0, bottom: 30.0, right: 20.0),
        width: .atMost(600.0),
        interSectionSpacingWithNoFooter: 20.0,
        interSectionSpacingWithFooter: 20.0,
        sectionHeaderBottomSpacing: 10.0,
        itemSpacing: 6.0,
        itemToSectionFooterSpacing: 10.0
    )
}

extension UIColor
{
    static func white(_ blend : CGFloat) -> UIColor
    {
        return UIColor(white: blend, alpha: 1.0)
    }
}


struct DemoHeader : BlueprintHeaderFooterElement, Equatable
{
    var title : String
    
    var element: Element {
        Label(text: self.title) {
            $0.font = .systemFont(ofSize: 16.0, weight: .semibold)
        }
        .inset(uniform: 10.0)
        .box(
            background: .white,
            corners: .rounded(radius: 10.0),
            borders: .solid(color: .white(0.85), width: 2.0)
        )
    }
}

struct DemoHeader2 : BlueprintHeaderFooterElement, Equatable
{
    var title : String
    
    var element: Element {
        Label(text: self.title) {
            $0.font = .systemFont(ofSize: 16.0, weight: .semibold)
        }
        .inset(top: 30.0, bottom: 30.0, left: 10.0, right: 10.0)
        .box(
            background: .init(white: 0.95, alpha: 1.0),
            corners: .rounded(radius: 10.0),
            borders: .solid(color: .white(0.85), width: 2.0)
        )
    }
}


struct DemoItem : BlueprintItemElement, Equatable
{
    var text : String
    
    var identifier: Identifier<DemoItem> {
        return .init(self.text)
    }

    typealias SwipeActionsAppearance = DefaultItemElementSwipeActionsAppearance
    
    func element(with info : ApplyItemElementInfo) -> Element
    {
        Label(text: self.text)
            .inset(uniform: 10.0)
    }
    
    func backgroundElement(with info: ApplyItemElementInfo) -> Element?
    {
        Box(
            backgroundColor: .white,
            cornerStyle: .rounded(radius: 6.0),
            borderStyle: .solid(color: .white(0.9), width: 2.0)
        )
    }
    
    func selectedBackgroundElement(with info: ApplyItemElementInfo) -> Element?
    {
        Box(
            backgroundColor: info.state.isSelected ? .white(0.9) : .white(0.95),
            cornerStyle: .rounded(radius: 6.0),
            borderStyle: .solid(color: .white(0.7), width: 2.0)
        )
    }
}


struct DemoFooter : BlueprintHeaderFooterElement, Equatable
{
    var text : String
    
    var element: Element {
        return Centered(Label(text: self.text))
    }
}


struct Toggle : Element {
    var isOn : Bool
    
    var onToggle : (Bool) -> ()
    
    var content: ElementContent {
        return ElementContent(layout: Layout())
    }
    
    func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription?
    {
        return ViewDescription(ToggleView.self) { config in
            config.builder = {
                return ToggleView()
            }
            
            config.apply { toggle in
                toggle.isOn = self.isOn
                toggle.onToggle = self.onToggle
            }
        }
    }
    
    private final class ToggleView : UISwitch
    {
        var onToggle : (Bool) -> () = { _ in }
        
        override init(frame: CGRect)
        {
            super.init(frame: frame)
            
            self.addTarget(self, action: #selector(toggled), for: .valueChanged)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        @objc func toggled()
        {
            self.onToggle(self.isOn)
        }
    }
    
    private struct Layout : BlueprintUI.Layout
    {
        static let measurementSwitch = ToggleView()
        
        func measure(in constraint: SizeConstraint, items: [(traits: (), content: Measurable)]) -> CGSize
        {
            return Layout.measurementSwitch.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        }
        
        func layout(size: CGSize, items: [(traits: (), content: Measurable)]) -> [LayoutAttributes]
        {
            return []
        }
    }
}
