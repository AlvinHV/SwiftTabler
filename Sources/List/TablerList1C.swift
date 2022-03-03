//
//  TablerList1C.swift
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

import CoreData
import SwiftUI

/// List-based table, with support for single-selection and bound values through Core Data
public struct TablerList1C<Element, Header, Row, Select>: View
    where Element: Identifiable & NSFetchRequestResult & ObservableObject,
    Header: View,
    Row: View,
    Select: View
{
    public typealias Config = TablerConfig<Element>
    public typealias Context = TablerContext<Element>
    public typealias Hovered = Element.ID?
    public typealias HeaderContent = (Binding<Context>) -> Header
    public typealias ProjectedValue = ObservedObject<Element>.Wrapper
    public typealias RowContent = (ProjectedValue) -> Row
    public typealias SelectContent = (Bool) -> Select
    public typealias Selected = Element.ID?
    public typealias Fetched = FetchedResults<Element>

    // MARK: Parameters

    private let config: Config
    private let headerContent: HeaderContent
    private let rowContent: RowContent
    private let selectContent: SelectContent
    private var results: Fetched
    @Binding private var selected: Selected

    public init(_ config: Config,
                @ViewBuilder headerContent: @escaping HeaderContent,
                @ViewBuilder rowContent: @escaping RowContent,
                @ViewBuilder selectContent: @escaping SelectContent,
                results: Fetched,
                selected: Binding<Selected>)
    {
        self.config = config
        self.headerContent = headerContent
        self.rowContent = rowContent
        self.selectContent = selectContent
        self.results = results
        _selected = selected
        _context = State(initialValue: TablerContext(config))
    }

    // MARK: Locals

    @State private var hovered: Hovered = nil
    @State private var context: Context

    // MARK: Views

    public var body: some View {
        BaseList1(context: $context,
                  selected: $selected,
                 headerContent: headerContent) {
            ForEach(results) { rawElem in
                ObservableHolder(element: rawElem) { obsElem in
                    rowContent(obsElem)
                        .modifier(ListRowMod(config, rawElem, $hovered))
                }
            }
            .onMove(perform: config.onMove)
        }
    }
}

public extension TablerList1C {
    // omitting Header
    init(_ config: Config,
         @ViewBuilder rowContent: @escaping RowContent,
         @ViewBuilder selectContent: @escaping SelectContent,
         results: Fetched,
         selected: Binding<Selected>)
        where Header == EmptyView
    {
        self.init(config,
                  headerContent: { _ in EmptyView() },
                  rowContent: rowContent,
                  selectContent: selectContent,
                  results: results,
                  selected: selected)
    }
    
    // omitting Select
    init(_ config: Config,
         @ViewBuilder headerContent: @escaping HeaderContent,
         @ViewBuilder rowContent: @escaping RowContent,
         results: Fetched,
         selected: Binding<Selected>)
        where Select == EmptyView
    {
        self.init(config,
                  headerContent: headerContent,
                  rowContent: rowContent,
                  selectContent: { _ in EmptyView() },
                  results: results,
                  selected: selected)
    }
    
    // omitting Header AND Select
    init(_ config: Config,
         @ViewBuilder rowContent: @escaping RowContent,
         results: Fetched,
         selected: Binding<Selected>)
    where Header == EmptyView, Select == EmptyView
    {
        self.init(config,
                  headerContent: { _ in EmptyView() },
                  rowContent: rowContent,
                  selectContent: { _ in EmptyView() },
                  results: results,
                  selected: selected)
    }
}