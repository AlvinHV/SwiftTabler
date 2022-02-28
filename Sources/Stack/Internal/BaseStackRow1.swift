//
//  BaseStackRow1.swift
//
// Copyright 2022 FlowAllocator LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import SwiftUI

// Row for stack-based list, with support for single-select
struct BaseStackRow1<Element, Row>: View
where Element: Identifiable,
      Row: View
{
    typealias Config = TablerStackConfig<Element>
    typealias Hovered = Element.ID?
    typealias Selected = Element.ID?
    typealias RowContent = () -> Row
    
    // MARK: Parameters
    
    var config: Config
    var element: Element
    @Binding var hovered: Hovered
    @Binding var selected: Selected
    var rowContent: RowContent
    
    // MARK: Locals
    
    // MARK: Views
    
    var body: some View {
        let colorPair = config.onRowColor?(element) // NOTE okay if nil
        
        LazyVGrid(columns: config.gridItems,
                  alignment: config.alignment) {
            rowContent()
        }
        .foregroundColor(colorPair?.0 ?? Color.primary)
        
        //            .overlay(
        //                SwSelectBorder(colorPair != nil && element == selected)
        //            )
        
#if os(macOS) || targetEnvironment(macCatalyst)
        // NOTE keeping selection part of mac, as on iOS you press to get the context menu
        .contentShape(Rectangle())
        .onTapGesture {
            selectAction(element)
        }
        //                            .onLongPressGesture {
        //                                selectAction(element)
        //                                guard canEdit else { return }
        //                                toEdit = element
        //                            }
#endif
        
        // Colored rows get their background here.
        // For non-colored rows, use accent color background to indicate selection.
#if os(macOS) || targetEnvironment(macCatalyst)
        // support hovering, but not for colored rows (yet)
        .onHover { if $0 { hovered = element.id } }
        
        // If hovering, set the background here.
        .background(colorPair?.1 ?? (
            element.id == selected ? Color.accentColor : (
                hovered == element.id ? Color.accentColor.opacity(0.2) : Color.clear
            )
        ))
#elseif os(iOS)
        .background(colorPair?.1 ?? (
            element.id == selected ? Color.accentColor : Color.clear
        ))
#endif
    }
    
    // MARK: Action Handlers
    
#if os(macOS) || targetEnvironment(macCatalyst)
    private func selectAction(_ element: Element) {
        selected = element.id
        // onSelect?(element)
    }
#endif
}