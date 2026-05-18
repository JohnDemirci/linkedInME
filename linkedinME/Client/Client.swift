//
//  Client.swift
//  linkedinME
//
//  Created by John Demirci on 3/27/26.
//

import FoundationModels

actor Client {
    enum Failure: Error, Hashable, Equatable {
        case appleIntelligenceNotEnabled
        case deviceNotEligible
        case modelNotReady
        case unknown
    }

    private let systemLanguageModel: SystemLanguageModel
    private let session: LanguageModelSession

    init() {
        self.systemLanguageModel = SystemLanguageModel(
            useCase: .general,
            guardrails: .permissiveContentTransformations
        )

        self.session = LanguageModelSession(
            model: self.systemLanguageModel,
            tools: [],
            instructions: """
            for the given input, translate it to a linkedin style text. No matter how ridiculus the input is, find a way to make it appropriate for a stereotypical linkedin post.
            
            The output should be at least 2 paragraphs or more. This depends on the length of the input
            You can use work style filler words and other work related gibbirish.
            Take each input lightly.
            
            The users should understand the context of the input from the output, so dont be extremely vague b
                
            In your response only contain the translated text ONLY. You do not need express your own feelings towards the prompt.
            """
        )

        session.prewarm()
    }

    func translate(_ text: String) async throws -> String {
        try checkAvailability()

        let mapped = """
        convert the text into a linked style post. Do not include your own opinions the output should only contain the converted text and nothing else.
        
        the input is: \(text)
        """

        return try await session.respond(to: mapped)
            .content
    }
}

extension Client {
    private func checkAvailability() throws {
        switch systemLanguageModel.availability {
        case .available:
            return

        case .unavailable(let reason):
            switch reason {
            case .appleIntelligenceNotEnabled:
                throw Failure.appleIntelligenceNotEnabled
            case .deviceNotEligible:
                throw Failure.deviceNotEligible
            case .modelNotReady:
                throw Failure.modelNotReady
            @unknown default:
                throw Failure.unknown
            }
        }
    }
}
