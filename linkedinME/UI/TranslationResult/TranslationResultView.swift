//
//  TranslationResultView.swift
//  linkedinME
//
//  Created by John Demirci on 3/28/26.
//

import SwiftUI
import UIKit
import Supervision

struct TranslationResultView: View {
    private let feature: TranslationFeature

    init(feature: TranslationFeature) {
        self.feature = feature
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                ResultHeaderView()
                OutputCardView()
                    .environment(feature)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(BackgroundView())
    }
}

private struct ResultHeaderView: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 4) {
                Text("Success")
                    .font(.subheadline.weight(.semibold))
                Text("Your LinkedIn-ready post is ready.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct OutputCardView: View {
    @Environment(TranslationFeature.self)
    private var feature

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            OutputCardTitleView()
            OutputTextView()
            TranslationActionOptionsView()
        }
        .padding(14)
        .background(OutputCardViewBackground())
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.35), lineWidth: 1)
        }
    }
}

private struct OutputCardTitleView: View {
    @Environment(TranslationFeature.self)
    private var feature

    var body: some View {
        Label(feature.outputCardTitleLabelText, systemImage: feature.outputCardTitleLabelSystemImageString)
            .font(.title2.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}

private struct OutputTextView: View {
    @Environment(TranslationFeature.self)
    private var feature

    var body: some View {
        Text(feature.output.value ?? "")
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .textSelection(.enabled)
    }
}

private struct TranslationActionOptionsView: View {
    var body: some View {
        HStack {
            ShareButton()
            CopyButtonView()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

private struct CopyButtonView: View {
    @Environment(TranslationFeature.self)
    private var feature

    var body: some View {
        Button(
            action: {
                feature.send(.copyToClipboard)
            },
            label: {
                Label(feature.copyButtonText, systemImage: feature.copyButtonSystemImageString)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
            }
        )
        .buttonStyle(.bordered)
        .tint(.secondary)
    }
}

private struct ShareButton: View {
    @Environment(TranslationFeature.self)
    private var feature

    var body: some View {
        Button(action: {}) {
            Label(feature.shareButtonLabelText, systemImage: feature.shareButtonSystemImageString)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
        .tint(.secondary)
    }
}

private struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.green.opacity(0.08),
                Color.blue.opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct OutputCardViewBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.thinMaterial)
            .shadow(
                color: colorScheme == .dark ? .gray.opacity(0.45) : .black.opacity(0.08),
                radius: 12,
                x: 0,
                y: 6
            )
    }
}

//#Preview {
//    @Previewable
//    @State
//    var feature = TranslationFeature.makePreview(
//        state: Translation.State(
//            output: .loaded("Some sample text to show the converted text"),
//        )
//    ) {
//        switch $0 {
//        case .inputChanged, .translateResult:
//            return nil
//        case .translate:
//            return .translateResult(.success("failure"))
//        default:
//            return nil
//        }
//    }
//
//    TranslationResultView(feature: feature)
//}
