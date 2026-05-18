//
//  TranslationFeature.swift
//  linkedinME
//
//  Created by John Demirci on 3/27/26.
//

import Supervision
import ValueObservation

typealias TranslationFeature = Feature<Translation>

struct Translation: FeatureBlueprint {
    enum Cancel: Hashable, Sendable {
        case translation
    }

    @ObservableValue
    struct State {
        var input: String
        var output: LoadableValue<String, Error>
        var showOutputView: Bool
        var didCopyToClipboard: Bool

        var copyButtonText: String {
            if didCopyToClipboard {
                return "Copied!"
            }
            return "Copy"
        }

        var copyButtonSystemImageString: String {
            if didCopyToClipboard {
                return "checkmark"
            }

            return "doc.on.doc"
        }

        var shareButtonLabelText: String { "Share" }
        var shareButtonSystemImageString: String { "square.and.arrow.up" }
        var outputCardTitleLabelText: String { "Output" }
        var outputCardTitleLabelSystemImageString: String { "text.quote" }

        init(
            input: String = "",
            output: LoadableValue<String, Error> = .idle,
            showOutputView: Bool = false,
            didCopyToClipboard: Bool = false
        ) {
            self.input = input
            self.output = output
            self.showOutputView = showOutputView
            self.didCopyToClipboard = didCopyToClipboard
        }
    }

    enum Action {
        case copyToClipboard
        case didStartCopyingClipboard
        case didFinishCopyingClipboard
        case inputChanged(String)
        case translate
        case translateResult(Result<String, Error>)
    }

    struct Dependency {
        let client: Client
        let clipboard: Clipboard
    }

    func process(action: Action, context: borrowing Context<State>) -> FeatureWork {
        switch action {
        case .copyToClipboard:
            guard case .loaded(let converted) = context.output else {
                return .done
            }

            return .run { dependency in
                await dependency.clipboard.copy(converted)
            } map: { _ in
                .didStartCopyingClipboard
            }

        case .didStartCopyingClipboard:
            context.didCopyToClipboard = true
            return .send(.didFinishCopyingClipboard)
                .debounce(for: .seconds(1))

        case .didFinishCopyingClipboard:
            context.didCopyToClipboard = false
            return .done

        case .inputChanged(let newInput):
            context.input = newInput
            return .done

        case .translate:
            context.output = .loading
            let input = context.input

            return .run(
                body: { dependency in
                    try await dependency.client.translate(input)
                },
                map: { result in
                    .translateResult(result)
                }
            )
            .cancellable(id: Cancel.translation, cancelInFlight: true)
            .throttle(for: .seconds(0.5))

        case .translateResult(let result):
            switch result {
            case .success(let output):
                context.output = .loaded(output)
                context.showOutputView = true
            case .failure(let error):
                context.output = .failure(error)
            }

            return .done
        }
    }
}

extension FeatureContainer where Dependency == AppEnvironment {
    func translationFeature() -> TranslationFeature {
        feature(
            state: TranslationFeature.State()) { dependency in
                TranslationFeature.Dependency(
                    client: dependency.client,
                    clipboard: dependency.clipboard
                )
            }
    }
}
