//
//  MainView.swift
//  RemberCore
//
//  Created by Alex Balla on 05.08.2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct MainView: View {
    var folderCode: String
    @State private var showCreateAlert: Bool = false
    @State private var alertTextFieldText: String = ""
    @State private var subFolders: [String] = []
    @State private var navigateToSubFolder: Bool = false
    @State private var selectedSubFolder: String = ""
    private let db = Firestore.firestore()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(subFolders, id: \.self) { subFolder in
                    Text(subFolder)
                        .onTapGesture {
                            navigateToSubFolder = true
                            selectedSubFolder = subFolder
                        }
                }
                .onDelete(perform: deleteSubFolder)
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(folderCode)
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                getSubFolders()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showCreateAlert = true
                    }) {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }.alert(
                        Text("New gallery"),
                        isPresented: $showCreateAlert
                    ) {
                        Button("Cancel", role: .cancel) {}
                        Button("Create") {
                            if !alertTextFieldText.isEmpty {
                                subFolders.append(alertTextFieldText)
                                createAPlaceholderForSubFolder(title: alertTextFieldText)
                                alertTextFieldText = ""
                                saveSubFolders()
                            }
                        }

                        TextField("Title", text: $alertTextFieldText)
                            .textContentType(.creditCardNumber)
                    } message: {
                       Text("Please create new subfolder")
                    }
                }
            }
        }
        
        NavigationLink(
            destination: DetailView(selectedSubFolder: selectedSubFolder, folderCode: folderCode),
            isActive: $navigateToSubFolder,
            label: { EmptyView() }
        )
    }
    
    private func createAPlaceholderForSubFolder(title: String) {
        guard !title.isEmpty else { return }
        
        let storage = Storage.storage()
        let storageRef = storage.reference().child("/\(folderCode)/\(title)/placeholder.txt")
        let placeholderText = "This is a placeholder text."
        let data = placeholderText.data(using: .utf8)

        let uploadTask = storageRef.putData(data!, metadata: nil) { metadata, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
            } else {
                print("Upload successful")
            }
        }
    }
    
    private func saveSubFolders() {
        let folderName: String = "folder_\(folderCode)"
        db.collection("codes").document(folderName).updateData(["subFolders":subFolders]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("subFolders were successfully saved")
                getSubFolders()
            }
        }
    }
    
    private func deleteSubFolder(at offsets: IndexSet) {
        subFolders.remove(atOffsets: offsets)
        saveSubFolders()
    }
    
    private func getSubFolders() {
        let folderName: String = "folder_\(folderCode)"
        db.collection("codes").document(folderName).getDocument(){ (document, error) in
            if let document = document, document.exists {
                let storedSubFolders = document.get("subFolders") as? [String] ?? []
                subFolders = storedSubFolders
            }
        }
    }
}

struct DetailView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var isUploading = false
    @State private var showImagePicker = false
    @State private var imageUrls: [URL] = []
    @State private var isLoading: Bool = false
    var selectedSubFolder: String
    var folderCode: String
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading images...")
                } else {
                    ScrollView {
                        ForEach(imageUrls, id: \.self) { url in
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle(selectedSubFolder)
        .onAppear{
            fetchJpgImages(from: "/\(folderCode)/\(selectedSubFolder)")
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: {
                    showImagePicker = true
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
                if selectedImage != nil {
                    Button(action: {
                        if let image = self.selectedImage {
                        isUploading = true
                        uploadImageToFirebase(image, to: "/\(folderCode)/\(selectedSubFolder)") { result in
                            isUploading = false
                            switch result {
                                case .success(let url):
                                    print("Image uploaded successfully: \(url)")
                                    fetchJpgImages(from: "/\(folderCode)/\(selectedSubFolder)")
                                case .failure(let error):
                                    print("Failed to upload image: \(error.localizedDescription)")
                                }
                            }
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .imageScale(.large)
                    }
                    .disabled(isUploading || selectedImage == nil)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
    }
    
    private func fetchJpgImages(from directory: String) {
        isLoading = true
        let storage = Storage.storage()
        let folderRef = storage.reference().child(directory)
            
        folderRef.listAll { result in
            switch result {
            case .success(let storageListResult):
                let jpgFiles = storageListResult.items.filter { $0.name.hasSuffix(".jpg") }
                var urls: [URL] = []
                    
                let dispatchGroup = DispatchGroup()
                    
                for fileRef in jpgFiles {
                    dispatchGroup.enter()
                    fileRef.downloadURL { url, error in
                        if let error = error {
                            print("Error downloading URL: \(error.localizedDescription)")
                        } else if let url = url {
                            print("Appended: \(url)")
                            urls.append(url)
                        }
                        dispatchGroup.leave()
                    }
                }
                    
                dispatchGroup.notify(queue: .main) {
                    self.imageUrls = urls
                    self.isLoading = false
                }

            case .failure(let error):
                print("Error listing files in folder: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
    
    private func uploadImageToFirebase(_ image: UIImage, to folder: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert UIImage to JPEG data")
            return
        }
        
        let fileName = UUID().uuidString + ".jpg"
        let storageRef = Storage.storage().reference().child("\(folder)/\(fileName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uploadTask = storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                if let url = url {
                    print("Image uploaded successfully. Download URL: \(url.absoluteString)")
                    completion(.success(url))
                }
            }
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            print("Upload is \(percentComplete * 100)% complete")
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                self.parent.selectedImage = image as? UIImage
            }
        }
    }
}

/* MARK: For future use
 MARK: Cannot use mutating member on immutable value: 'self' is immutable
 Fix:
 If it is a property of struct - put @State before
 Else if it is function, put the word mutating before
 */
