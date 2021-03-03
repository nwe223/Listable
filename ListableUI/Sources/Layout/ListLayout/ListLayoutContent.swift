//
//  ListLayoutContent.swift
//  ListableUI
//
//  Created by Kyle Van Essen on 6/7/20.
//

import Foundation


public final class ListLayoutContent
{
    var contentSize : CGSize
        
    let header : SupplementaryItemInfo
    let footer : SupplementaryItemInfo
    
    let overscrollFooter : SupplementaryItemInfo
    
    let sections : [SectionInfo]
    
    var all : [ListLayoutContentItem] {
        var all : [ListLayoutContentItem] = []
        
        if header.isPopulated {
            all.append(header)
        }
        
        all += sections.flatMap { $0.all }
        
        if footer.isPopulated {
            all.append(footer)
        }
        
        return all
    }
    
    init()
    {
        self.contentSize = .zero
        
        self.header = SupplementaryItemInfo.empty(.listHeader)
        self.footer = SupplementaryItemInfo.empty(.listFooter)
        self.overscrollFooter = SupplementaryItemInfo.empty(.overscrollFooter)
        
        self.sections = []
    }
    
    init(
        header : SupplementaryItemInfo?,
        footer : SupplementaryItemInfo?,
        overscrollFooter : SupplementaryItemInfo?,
        sections : [SectionInfo]
    ) {
        self.contentSize = .zero
        
        self.header = header ?? .empty(.listHeader)
        self.footer = footer ?? .empty(.listFooter)
        self.overscrollFooter = overscrollFooter ?? .empty(.overscrollFooter)
        self.sections = sections
    }
    
    //
    // MARK: Fetching Elements
    //
    
    func layoutAttributes(at indexPath : IndexPath) -> UICollectionViewLayoutAttributes
    {
        let item = self.item(at: indexPath)
        
        return item.layoutAttributes(with: indexPath)
    }
    
    func item(at indexPath : IndexPath) -> ListLayoutContent.ItemInfo
    {
        return self.sections[indexPath.section].items[indexPath.item]
    }
    
    func supplementaryLayoutAttributes(of kind : String, at indexPath : IndexPath) -> UICollectionViewLayoutAttributes?
    {
        let section = self.sections[indexPath.section]
        
        switch SupplementaryKind(rawValue: kind)! {
        case .listHeader: return self.header.layoutAttributes(with: indexPath)
        case .listFooter: return self.footer.layoutAttributes(with: indexPath)
            
        case .sectionHeader: return section.header.layoutAttributes(with: indexPath)
        case .sectionFooter: return section.footer.layoutAttributes(with: indexPath)
            
        case .overscrollFooter: return self.overscrollFooter.layoutAttributes(with: indexPath)
        }
    }
    
    func layoutAttributes(in rect: CGRect, alwaysIncludeOverscroll : Bool) -> [UICollectionViewLayoutAttributes]
    {
        /**
         Supplementary items are technically attached to index paths. Eg, list headers
         and footers are attached to (0,0), and section headers and footers are attached to
         (sectionIndex, 0). Because of this, we can't return any list headers or footers
         unless there's at least one section – the collection view will not have anything to
         attach them to, and will then crash.
         */
        guard self.sections.isEmpty == false else {
            return []
        }
        
        var attributes = [UICollectionViewLayoutAttributes]()
        
        // List Header
        
        if rect.intersects(self.header.visibleFrame) {
            attributes.append(self.header.layoutAttributes(with: self.header.kind.indexPath(in: 0)))
        }
        
        // Sections
        
        self.sections.forEachForwardFrom { section in
            .compare(frame: section.contentsFrame, in: rect, direction: .vertical) // TODO fixme: Not only vertical
        } forEach: { sectionIndex, section in
            
            guard rect.intersects(section.contentsFrame) else {
                return false
            }
            
            // Section Header
            
            if rect.intersects(section.header.visibleFrame) {
                attributes.append(section.header.layoutAttributes(with: section.header.kind.indexPath(in: sectionIndex)))
            }
            
            // Items
                        
            section.items.forEachForwardFrom { item in
                .compare(frame: item.frame, in: rect, direction: .vertical) // TODO fixme: Not only vertical
            } forEach: { _, item in
                if rect.intersects(item.frame) {
                    attributes.append(item.layoutAttributes(with: item.liveIndexPath))
                    return true
                } else {
                    return false
                }
            }
            
            // Section Footer
            
            if rect.intersects(section.footer.visibleFrame) {
                attributes.append(section.footer.layoutAttributes(with: section.footer.kind.indexPath(in: sectionIndex)))
            }
            
            return true
        }
        
        // List Footer
        
        if rect.intersects(self.footer.visibleFrame) {
            attributes.append(self.footer.layoutAttributes(with: self.footer.kind.indexPath(in: 0)))
        }
        
        // Overscroll Footer
        
        if alwaysIncludeOverscroll || rect.intersects(self.overscrollFooter.visibleFrame) {
            // Don't check the rect for the overscroll view as we do with other views; it's always outside of the contentSize.
            // Instead, just return it all the time to ensure the collection view will display it when needed.
            attributes.append(self.overscrollFooter.layoutAttributes(with: self.overscrollFooter.kind.indexPath(in: 0)))
        }
        
        return attributes
    }
    
    //
    // MARK: Performing Layouts
    //
    
    func setSectionContentsFrames() {
        self.sections.forEach {
            $0.setContentsFrame()
        }
    }
    
    func reindexLiveIndexPaths()
    {
        self.sections.forEachWithIndex { sectionIndex, _, section in
            section.items.forEachWithIndex { itemIndex, _, item in
                item.liveIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
    }
    
    func reindexDelegateProvidedIndexPaths()
    {
        self.sections.forEachWithIndex { sectionIndex, _, section in
            section.items.forEachWithIndex { itemIndex, _, item in
                item.delegateProvidedIndexPath = IndexPath(item: itemIndex, section: sectionIndex)
            }
        }
    }
    
    func move(from : IndexPath, to : IndexPath)
    {
        guard from != to else {
            return
        }
        
        let info = self.item(at: from)
        
        self.sections[from.section].items.remove(at: from.item)
        self.sections[to.section].items.insert(info, at: to.item)
    }
    
    //
    // MARK: Layout Data
    //
    
    var layoutAttributes : ListLayoutAttributes {
        ListLayoutAttributes(
            contentSize: self.contentSize,
            header: self.header.isPopulated ? .init(frame: self.header.defaultFrame) : nil,
            footer: self.footer.isPopulated ? .init(frame: self.footer.defaultFrame) : nil,
            overscrollFooter: self.overscrollFooter.isPopulated ? .init(frame: self.overscrollFooter.defaultFrame) : nil,
            sections: self.sections.map { section in
                .init(
                    frame: section.contentsFrame,
                    header: section.header.isPopulated ? .init(frame: section.header.defaultFrame) : nil,
                    footer: section.footer.isPopulated ? .init(frame: section.footer.defaultFrame) : nil,
                    items: section.items.map { item in
                        .init(frame: item.frame)
                    }
                )
            }
        )
    }
}


protocol ListLayoutContentItem : AnyObject
{
    var size : CGSize { get set }
    var x : CGFloat { get set }
    var y : CGFloat { get set }
    
    var zIndex : Int { get set }
}


public extension ListLayoutContent
{
    final class SectionInfo
    {
        let layouts : SectionLayouts
        
        let header : SupplementaryItemInfo
        let footer : SupplementaryItemInfo
                
        var items : [ItemInfo]
        
        var all : [ListLayoutContentItem] {
            var all : [ListLayoutContentItem] = []
            
            if header.isPopulated {
                all.append(header)
            }
            
            all += self.items
            
            if footer.isPopulated {
                all.append(footer)
            }
            
            return all
        }
        
        private(set) var contentsFrame : CGRect
                
        init(
            layouts : SectionLayouts,
            header : SupplementaryItemInfo?,
            footer : SupplementaryItemInfo?,
            items : [ItemInfo]
        ) {
            self.contentsFrame = .zero
            
            self.layouts = layouts
            
            self.header = header ?? .empty(.sectionHeader)
            self.footer = footer ?? .empty(.sectionFooter)
            
            self.items = items
        }
        
        func setContentsFrame() {
            
            var allFrames : [CGRect] = []
            
            if header.isPopulated {
                allFrames.append(header.defaultFrame)
            }
            
            allFrames += items.map { $0.frame }
            
            if footer.isPopulated {
                allFrames.append(footer.defaultFrame)
            }

            self.contentsFrame = .unioned(from: allFrames)
        }
    }

    final class SupplementaryItemInfo : ListLayoutContentItem
    {
        static func empty(_ kind : SupplementaryKind) -> SupplementaryItemInfo
        {
            SupplementaryItemInfo(
                kind: kind,
                layouts: .init(),
                isPopulated: false, measurer: { _ in .zero }
            )
        }
        
        let kind : SupplementaryKind
        let layouts : HeaderFooterLayouts
        let measurer : (Sizing.MeasureInfo) -> CGSize
                
        let isPopulated : Bool
                        
        var size : CGSize = .zero
        
        var x : CGFloat = .zero
        var pinnedX : CGFloat? = nil
        
        var y : CGFloat = .zero
        var pinnedY : CGFloat? = nil
        
        var zIndex : Int = 0
        
        var defaultFrame : CGRect {
            CGRect(
                origin: CGPoint(x: self.x, y: self.y),
                size: self.size
            )
        }
        
        var visibleFrame : CGRect {
            CGRect(
                origin: CGPoint(
                    x: self.pinnedX ?? self.x,
                    y: self.pinnedY ?? self.y
                ),
                size: self.size
            )
        }
        
        init(
            kind : SupplementaryKind,
            layouts : HeaderFooterLayouts,
            isPopulated: Bool,
            measurer : @escaping (Sizing.MeasureInfo) -> CGSize
        ) {
            self.kind = kind
            
            self.layouts = layouts
            self.isPopulated = isPopulated
            self.measurer = measurer
        }
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: self.kind.rawValue, with: indexPath)
            
            attributes.frame = self.visibleFrame
            attributes.zIndex = self.zIndex
            
            return attributes
        }
    }
    

    final class ItemInfo : ListLayoutContentItem
    {
        var delegateProvidedIndexPath : IndexPath
        var liveIndexPath : IndexPath
        
        let layouts : ItemLayouts
        
        let insertAndRemoveAnimations : ItemInsertAndRemoveAnimations
        let measurer : (Sizing.MeasureInfo) -> CGSize
        
        var position : ItemPosition = .single
                
        var size : CGSize = .zero
                
        var x : CGFloat = .zero
        var y : CGFloat = .zero
        
        var zIndex : Int = 0
        
        var frame : CGRect {
            CGRect(
                origin: CGPoint(x: self.x, y: self.y),
                size: self.size
            )
        }
        
        init(
            delegateProvidedIndexPath : IndexPath,
            liveIndexPath : IndexPath,
            layouts : ItemLayouts,
            insertAndRemoveAnimations : ItemInsertAndRemoveAnimations,
            measurer : @escaping (Sizing.MeasureInfo) -> CGSize
        ) {
            self.delegateProvidedIndexPath = delegateProvidedIndexPath
            self.liveIndexPath = liveIndexPath
                        
            self.layouts = layouts
            
            self.insertAndRemoveAnimations = insertAndRemoveAnimations
            
            self.measurer = measurer
        }
        
        func layoutAttributes(with indexPath : IndexPath) -> UICollectionViewLayoutAttributes
        {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            attributes.frame = self.frame
            attributes.zIndex = self.zIndex
            
            return attributes
        }
    }
}


extension CGRect {
    static func unioned(from rects : [CGRect]) -> CGRect {
        
        let rects = rects.filter {
            $0.isEmpty == false
        }
        
        guard let first = rects.first else {
            return .zero
        }

        var frame = first
        
        for rect in rects {
            frame = frame.union(rect)
        }
        
        return frame
    }
}


enum BinarySearchComparison : Equatable {
    
    case less
    case equal
    case greater
    
    static func compare(
        frame : CGRect,
        in parent : CGRect,
        direction : LayoutDirection
    ) -> Self
    {
        switch direction {
        case .vertical:
            if frame.maxY < parent.origin.y {
                return .less
            } else if frame.minY > parent.maxY {
                return .greater
            } else {
                return .equal
            }
            
        case .horizontal:
            fatalError("TODO")
        }
    }
}


extension Array {
    
    /// Implements a binary search to find the first object in an array
    /// that passes the given test, and then enumerates forwards until
    /// the `forEach` closure returns false.
    func forEachForwardFrom(
        first isFirst : (Element) -> BinarySearchComparison,
        forEach : (Int, Element) -> Bool
    ) {
        guard let start = self.forwardFrom(first: isFirst) else {
            return
        }
        
        for (index, item) in self[start..<self.endIndex].enumerated() {
            if forEach(index + start, item) == false { // TODO: I think the index here is wrong? Did the fix fix it?
                break
            }
        }
    }
    
    func forwardFrom(
        first isFirst : (Element) -> BinarySearchComparison
    ) -> Int?
    {
        guard let startGuess = self.binarySearch(for: isFirst, in: 0..<self.count) else {
            return nil
        }
        
        let slice = self[0...startGuess]
        
        for (index, element) in slice.reversed().enumerated() {
            let comparison = isFirst(element)
            
            if comparison == .less {
                return startGuess - index + 1
            }
        }
        
        return 0
    }
    
    func binarySearch(
        for find : (Element) -> BinarySearchComparison,
        in range : Range<Int>
    ) -> Int?
    {
        guard self.isEmpty == false else {
            return nil
        }
        
        var lower = 0
        var upper = self.count
        
        while lower < upper {
            let index = lower + (upper - lower) / 2
            
            let result = find(self[index])
            
            switch result {
            case .less:
                lower = index + 1
            case .equal:
                return index
            case .greater:
                upper = index
            }
        }
        
        return nil
    }
}
