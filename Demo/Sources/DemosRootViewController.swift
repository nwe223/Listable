//
//  TableViewDemosRootViewController.swift
//  CheckoutApplet
//
//  Created by Kyle Van Essen on 6/24/19.
//

import UIKit

import Listable


public final class DemosRootViewController : UIViewController
{    
    public struct State : Equatable {}
    
    let listView = ListView()
    
    func push(_ viewController : UIViewController)
    {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override public func loadView()
    {        
        self.title = "Demos"
        
        self.view = self.listView
        
        self.listView.appearance = demoAppearance
        
        self.listView.setContent { list in
            
            list.content.overscrollFooter = HeaderFooter(
                with: DemoHeader(title: "Thanks for using Listable!!")
            )
            
            list += Section(identifier: "collection-view") { section in
                
                section.header = HeaderFooter(
                    with: DemoHeader(title: "Collection Views")
                )
                
                section += Item(
                    DemoItem(text: "Basic Demo"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(CollectionViewBasicDemoViewController())
                })
                
                section += Item(
                    DemoItem(text: "Blueprint Integration"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(BlueprintListDemoViewController())
                })

                section += Item(
                    DemoItem(text: "Auto Scrolling (Bottom Pin)"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(AutoScrollingViewController())
                })
                
                section += Item(
                    DemoItem(text: "Custom Layouts"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(CustomLayoutsViewController())
                })
                
                section += Item(
                    DemoItem(text: "Itemization Editor"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(ItemizationEditorViewController())
                })
                
                section += Item(
                    DemoItem(text: "English Dictionary Search"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(CollectionViewDictionaryDemoViewController())
                })
                
                section += Item(
                    DemoItem(text: "Keyboard Testing"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(KeyboardTestingViewController())
                })
                
                section += Item(
                    DemoItem(text: "Horizontal Layout"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(HorizontalLayoutViewController())
                })
                
                section += Item(
                    DemoItem(text: "Width Customization"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(WidthCustomizationViewController())
                })
                
                section += Item(
                    DemoItem(text: "Reordering (Experimental)"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(ReorderingViewController())
                })
                
                section += Item(
                    DemoItem(text: "Invoices Payment Schedule"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(InvoicesPaymentScheduleDemoViewController())
                })
            }
            
            list += Section(identifier: "flow-layout") { section in
                
                section.header = HeaderFooter(
                    with: DemoHeader(title: "Flow Layouts")
                )
                
                section += Item(
                    DemoItem(text: "Flow Layout"),
                    selectionStyle: .tappable,
                    onSelect : { _ in
                        self.push(FlowLayoutViewController())
                })
            }
            
            list += Section(identifier: "table-view") { section in
                
                section.header = HeaderFooter(
                    with: DemoHeader(title: "Table Views")
                )
                
                section += Item(
                    DemoItem(text: "Swipe To Action"),
                    selectionStyle: .tappable,
                    swipeActions: SwipeActions(SwipeAction(
                        title: "Delete",
                        backgroundColor: .purple,
                        image: nil,
                        onTap: { _ in
                            print("Deleted")
                            return true
                        }
                    ),performsFirstOnFullSwipe: true),
                    swipeActionsAppearance: DefaultItemElementSwipeActionsAppearance(),
                    onSelect : { _ in
                        self.push(DemoTableViewController())
                })
            }
        }
    }
}

