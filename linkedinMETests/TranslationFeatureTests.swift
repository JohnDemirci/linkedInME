//
//  TranslationFeatureTests.swift
//  linkedinME
//
//  Created by John Demirci on 3/28/26.
//

import Testing
import Supervision
@testable import linkedinME

struct TranslationFeatureTests {
    enum Failure: Error {
        case failed
    }

    @Test
    func `copy to clipboard when the state is not loading returns a .done work`() throws {
        let tester = Tester<Translation>(
            initialState: .init(output: .idle)
        )

        try tester.send(.copyToClipboard)
            .assertDone()
    }

    @Test
    func `copy to clipboard in loaded output state calls .run`() throws {
        let tester = Tester<Translation>(
            initialState: .init(output: .loaded("something"))
        )

        #expect(tester.state.didCopyToClipboard == false)

        let copyToClipboardWork = try tester.send(.copyToClipboard)
            .assertRun()

        let finishCopyWork = try tester.feedResult(.success(()), inspection: copyToClipboardWork) { state in
            #expect(state.didCopyToClipboard == true)
            #expect(state.copyButtonText == "Copied!")
            #expect(tester.state.copyButtonSystemImageString == "checkmark")
        }
        .assertRun()

        try tester.feedResult(.success(()), inspection: finishCopyWork) { state in
            #expect(state.didCopyToClipboard == false)
            #expect(state.copyButtonText == "Copy")
            #expect(tester.state.copyButtonSystemImageString == "doc.on.doc")
        }
        .assertDone()
    }

    @Test(arguments: ["cat", "dog", "player"])
    func `change input action changes the state`(_ value: String) throws {
        let tester = Tester<Translation>(initialState: .init())

        try tester.send(.inputChanged(value)) { state in
            #expect(state.input == value)
        }
        .assertDone()
    }

    @Test
    func `translate action succeeds`() throws {
        let tester = Tester<Translation>(initialState: .init())

        let translateWork = try tester.send(.translate) { state in
            #expect(state.output == .loading)
        }
        .assertRun()

        try tester.feedResult(.success("translated"), inspection: translateWork) { state in
            #expect(state.showOutputView == true)
            #expect(state.output == .loaded("translated"))
        }
        .assertDone()
    }

    @Test
    func `translate action fails`() throws {
        let tester = Tester<Translation>(initialState: .init())

        let translateWork = try tester.send(.translate) { state in
            #expect(state.output == .loading)
        }
        .assertRun()

        #expect(translateWork.cancelInFlight == true)
        #expect(translateWork.id == AnyHashableSendable(value: Translation.Cancel.translation))
        #expect(translateWork.throttle == .seconds(0.5))

        let result: Result<String, Error> = .failure(Failure.failed)

        try tester.feedResult(result, inspection: translateWork) { state in
            #expect(state.showOutputView == false)
            #expect(state.output == .failure(Failure.failed))
        }
        .assertDone()
    }
}
