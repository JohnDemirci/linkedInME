//
//  TranslationView.swift
//  linkedinME
//
//  Created by John Demirci on 3/28/26.
//

import FoundationModels
import SwiftUI
import Supervision

struct TranslationView: View {
    @State private var feature: TranslationFeature
    @State private var errorMessage: String = ""
    @State private var showErrror: Bool = false

    init(feature: TranslationFeature) {
        self.feature = feature
    }

    var body: some View {
        ZStack {
            InputView(feature: feature)

            ProgressView()
                .progressViewStyle(.circular)
                .isHiddenWhen(!feature.output.isLoading)
        }
        .onStateChange(of: feature.output, onFailure: { error in
            self.errorMessage = error.localizedDescription
            self.showErrror = true
        })
        .sheet(isPresented: feature.directBinding(\.showOutputView)) {
            TranslationResultView(feature: feature)
        }
        .alert("Error", isPresented: $showErrror) {
            Button("Dismiss") {
                errorMessage = ""
            }
        } message: {
            Text(errorMessage)
        }
    }
}

private struct InputView: View {
    private let feature: TranslationFeature

    init(feature: TranslationFeature) {
        self.feature = feature
    }

    var body: some View {
        VStack(spacing: 20) {
            InputHeaderView(feature: feature)
            InputTextEditorView(feature: feature)
        }
        .padding([.horizontal, .top], 20)
        .overlay(alignment: .bottomTrailing) {
            TranslateButton(feature: feature)
        }
    }
}

private struct InputHeaderView: View {
    private let feature: TranslationFeature

    init(feature: TranslationFeature) {
        self.feature = feature
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TitleView()
            SubtitleView()
            CharacterCountView(feature: feature)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct InputTextEditorView: View {
    private let feature: TranslationFeature

    @FocusState private var isFirstResponder: Bool

    init(feature: TranslationFeature) {
        self.feature = feature
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Text("Example: I am going to jail for being too handsome")
                .foregroundStyle(.tertiary)
                .padding(.top, 8)
                .padding(.leading, 5)
                .isHiddenWhen(!feature.input.isEmpty)

            TextEditor(
                text: feature.binding(
                    \.input,
                     send: { input in
                        .inputChanged(input)
                     }
                )
            )
            .focused($isFirstResponder)
            .frame(minHeight: 220)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .onAppear {
            isFirstResponder = true
        }
    }
}

private struct TranslateButton: View {
    private let feature: TranslationFeature

    init(feature: TranslationFeature) {
        self.feature = feature
    }

    var body: some View {
        Button(
            action: {
                feature.send(.translate)
            },
            label: {
                ButtonLabel()
                    .padding()
                    .background(ButtonBackground())
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        )
        .padding()
        .disabled(feature.output.isLoading)
        .shadow(radius: 10)
    }
}

private struct ButtonLabel: View {
    var body: some View {
        HStack {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.white)
            Text("Link it in")
                .foregroundStyle(.white)
        }
    }
}

private struct ButtonBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.purple,
                Color.blue
            ],
            startPoint: .topLeading,
            endPoint: .bottom
        )
    }
}

private extension InputHeaderView {
    struct TitleView: View {
        var body: some View {
            Text("Turn anything into a LinkedIn post")
                .font(.title2.weight(.bold))
        }
    }

    struct SubtitleView: View {
        var body: some View {
            Text("Write something casual, ridiculous, or rough. The AI will rewrite it into a polished post.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    struct CharacterCountView: View {
        private let feature: TranslationFeature

        init(feature: TranslationFeature) {
            self.feature = feature
        }

        var body: some View {
            HStack {
                Label("Your input", systemImage: "square.and.pencil")
                    .font(.headline)

                Spacer()

                Text("\(feature.input.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 10)
        }
    }
}

#if DEBUG
extension String: @retroactive Error {}
#endif

//#Preview {
//    @Previewable
//    @State
//    var feature = TranslationFeature.makePreview(
//        state: TranslationFeature.State()) { action in
//            switch action {
//            case .inputChanged, .translateResult:
//                return nil
//            case .translate:
//                return .translateResult(.success("success result"))
//            default:
//                return nil
//            }
//        }
//
//    TranslationView(feature: feature)
//}
