//
//  LoadableValue.swift
//  linkedinME
//
//  Created by John Demirci on 3/27/26.
//

import Foundation
import SwiftUI

enum LoadableValue<Value, Failure: Error> {
    case idle
    case loading
    case failure(Failure)
    case loaded(Value)

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var value: Value? {
        guard case .loaded(let value) = self else {
            return nil
        }
        return value
    }
}

extension LoadableValue: Equatable where Value: Equatable {
    static func == (lhs: LoadableValue<Value, Failure>, rhs: LoadableValue<Value, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.failure, .failure):
            return true
        case let (.loaded(lhsValue), .loaded(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

extension LoadableValue: Hashable where Value: Hashable, Failure: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .idle:
            hasher.combine(0)
        case .loading:
            hasher.combine(1)
        case .failure(let error):
            hasher.combine(2)
            hasher.combine(error)
        case let .loaded(value):
            hasher.combine(3)
            hasher.combine(value)
        }
    }
}

extension LoadableValue: Sendable where Value: Sendable, Failure: Sendable {}

extension View {
    @ViewBuilder
    func onStateChange<Value: Equatable, Failure: Error>(
        of state: LoadableValue<Value, Failure>,
        onFailure: ((Failure) -> Void)? = nil,
        onCompletion: ((Value) -> Void)? = nil,
        onLoading: (() -> Void)? = nil,
        onIdle: (() -> Void)? = nil,
    ) -> some View {
        onChange(of: state) { oldValue, newValue in
            switch newValue {
            case .failure(let error):
                onFailure?(error)
            case .loaded(let value):
                onCompletion?(value)
            case .idle:
                onIdle?()
            case .loading:
                onLoading?()
            }
        }
    }
}
