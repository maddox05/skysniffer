//
//  ContentView.swift
//  test_app
//
//  Created by Maddox Schmidlkofer on 12/1/25.
//

import SwiftUI
import SwiftData
import PhotosUI
import SuperwallKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \ScanResult.timestamp, order: .reverse) private var scans: [ScanResult]
    @State private var viewModel = ScanViewModel()
    @State private var showingSettings = false

    var body: some View {
        ZStack {
            if viewModel.showingOnboarding {
                OnboardingView {
                    // TODO: Re-enable Superwall when ready
                    // Register the paywall placement
                    // Superwall.shared.register(placement: "campaign_trigger")

                    // Complete onboarding after paywall is dismissed
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        viewModel.completeOnboarding()
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                mainContent
                    .transition(.opacity.combined(with: .scale(scale: 1.05)))
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.showingOnboarding)
    }

    private var mainContent: some View {
        NavigationStack {
            ZStack {
                // Main content - full screen
                if scans.isEmpty {
                    EmptyStateView()
                } else {
                    scanListView
                }

                // Floating scan button at bottom
                VStack {
                    Spacer()
                    ScanButton {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.showingImagePicker = true
                        }
                    }
                    .padding(.bottom, 30)
                }

                if viewModel.isScanning {
                    ScanningView(image: viewModel.selectedImage)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }

                if viewModel.showingImagePicker {
                    imagePickerOverlay
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isScanning)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showingImagePicker)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(colorScheme == .dark ? "App Icon White" : "App Icon Black")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                        Text("SkySniffer")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .frame(height: 44)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Settings")
                    .accessibilityHint("Open app settings and information")
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: Binding(
                get: { viewModel.showingCamera },
                set: { viewModel.showingCamera = $0 }
            )) {
                CustomCameraView(
                    image: Binding(
                        get: { viewModel.selectedImage },
                        set: { viewModel.selectedImage = $0 }
                    ),
                    isPresented: Binding(
                        get: { viewModel.showingCamera },
                        set: { viewModel.showingCamera = $0 }
                    )
                )
            }
            .photosPicker(
                isPresented: Binding(
                    get: { viewModel.showingPhotosPicker },
                    set: { viewModel.showingPhotosPicker = $0 }
                ),
                selection: Binding(
                    get: { viewModel.selectedPhotoItem },
                    set: { viewModel.selectedPhotoItem = $0 }
                ),
                matching: .images
            )
            .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                viewModel.handlePhotoSelection()
            }
            .sheet(isPresented: Binding(
                get: { viewModel.showingResult },
                set: { viewModel.showingResult = $0 }
            )) {
                if let result = viewModel.currentResult, let image = viewModel.selectedImage {
                    ResultView(result: result, image: image) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.showingResult = false
                        }
                        Task {
                            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                            await MainActor.run {
                                viewModel.saveResult()
                            }
                        }
                    }
                    .presentationDragIndicator(.visible)
                }
            }
            .onChange(of: viewModel.selectedImage) { _, newValue in
                if let image = newValue {
                    viewModel.performScan(image: image)
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
            .alert("Unable to Analyze", isPresented: $viewModel.showingError) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
                if viewModel.selectedImage != nil {
                    Button("Try Again") {
                        if let image = viewModel.selectedImage {
                            viewModel.performScan(image: image)
                        }
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "An unexpected error occurred. Please try again.")
            }
        }
    }

    private var scanListView: some View {
        List {
            ForEach(scans) { scan in
                NavigationLink {
                    if let imageData = scan.imageData,
                       let image = UIImage(data: imageData) {
                        SavedScanDetailView(scan: scan, image: image)
                    }
                } label: {
                    ScanRowView(scan: scan)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
            .onDelete { offsets in
                // Haptic feedback on delete
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()

                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.deleteScans(at: offsets, from: scans)
                }
            }

            // Add bottom padding to prevent list items from being hidden behind button
            Color.clear
                .frame(height: 100)
                .listRowBackground(Color.clear)
        }
        .listStyle(.insetGrouped)
        .refreshable {
            // Haptic feedback on refresh
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()

            // Small delay to show refresh animation
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
    }

    private var imagePickerOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        viewModel.showingImagePicker = false
                    }
                }
                .transition(.opacity)

            VStack {
                Spacer()
                ImageSourcePicker {
                    viewModel.showingImagePicker = false
                    viewModel.showingCamera = true
                } onChooseLibrary: {
                    viewModel.showingImagePicker = false
                    viewModel.showingPhotosPicker = true
                }
                .padding(.bottom, 150)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

// Helper view for displaying saved scan details with proper dismiss
struct SavedScanDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let scan: ScanResult
    let image: UIImage

    var body: some View {
        ResultView(
            result: scan.asDetectionResult,
            image: image,
            onDone: {
                dismiss()
            }
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}


