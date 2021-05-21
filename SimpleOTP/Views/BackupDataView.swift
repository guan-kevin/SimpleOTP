//
//  BackupDataView.swift
//  SimpleOTP
//
//  Created by Kevin Guan on 5/20/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct BackupDataView: View {
    @EnvironmentObject var model: MainViewModel

    @State private var showExporter = false
    @State private var showImporter = false

    @State var passwordText = ""
    @State var backupBase64 = ""
    @State var showAlert = false
    @State var alertMessage = ""

    var body: some View {
        Group {
            Form {
                Section(header: Text("Please set a password with more than 5 characters first."), footer: Text("Import backup data will override your current data!")) {
                    SecureField("Password", text: $passwordText)

                    if model.otps.count > 0 {
                        Button(action: {
                            let result = EncryptionHelper.encryptData(otps: self.model.otps, key: passwordText)

                            if result != nil {
                                backupBase64 = result!
                                showExporter = true
                            }
                        }) {
                            Text("Backup my data")
                        }
                        .disabled(passwordText.count <= 5)
                    }

                    Button(action: {
                        self.showImporter = true
                    }) {
                        Text("Import my backup data")
                    }
                    .disabled(passwordText.count <= 5)
                }
            }
            .fileExporter(isPresented: $showExporter, document: BackupFile(input: backupBase64), contentType: .plainText, defaultFilename: "SimpleOTP_backup") { result in
                switch result {
                case .success:
                    self.backupBase64 = ""
                    self.passwordText = ""

                    self.alertMessage = "Done!"
                    self.showAlert = true
                case .failure(let error):
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.plainText], allowsMultipleSelection: false, onCompletion: { result in
                if let url = try? result.get().first {
                    if let data = try? Data(contentsOf: url) {
                        let base64 = String(decoding: data, as: UTF8.self)

                        let otps = EncryptionHelper.decryptData(data: base64, key: passwordText)
                        if otps != nil {
                            self.passwordText = ""
                            self.model.otps = otps!
                            self.model.saveAllOTPs()
                            self.alertMessage = "Done!"
                            self.showAlert = true
                            return
                        }
                    }
                }

                self.alertMessage = "Unable to import this data, check your password and try again!"
                self.showAlert = true
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text(self.alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarTitle("Backup/Import", displayMode: .inline)
        }
    }
}

struct BackupFile: FileDocument {
    static var readableContentTypes = [UTType.plainText]

    var base64 = ""

    init(input: String = "") {
        base64 = input
    }

    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            base64 = String(decoding: data, as: UTF8.self)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(base64.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
