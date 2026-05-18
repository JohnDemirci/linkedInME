//
//  View.swift
//  linkedinME
//
//  Created by John Demirci on 3/28/26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func isHiddenWhen(_ bool: Bool) -> some View {
        if !bool {
            self
        } else {
            EmptyView()
        }
    }
}
