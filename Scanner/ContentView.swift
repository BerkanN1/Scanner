//
//  ContentView.swift
//  Scanner
//
//  Created by BERKAN NALBANT on 14.01.2023.
//

import SwiftUI
import PDFKit


struct ContentView: View {
   
    @State private var showScannerSheet = false
    @State private var texts:[ScanData] = []
    @State private var showingAlert = false
    @State private var textFieldValue = ""
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: Scanned.entity(), sortDescriptors:[NSSortDescriptor(keyPath:\Scanned.text, ascending: true)]) var items: FetchedResults<Scanned>

    var body: some View {
        
        NavigationView{
            VStack{
                
                if items.count > 0{
            
                    List{
                        ForEach(items){item in
                        HStack{
                            NavigationLink(destination: ScrollView{Text(item.text ?? "hata")}, label: {
                                Text(item.text ?? "hata").lineLimit(1)
                            })
                            
                                Button("->") {
                                    showingAlert = true
                                }
                                .buttonStyle(.borderedProminent)
                                .alert("Dosya Adı", isPresented: $showingAlert, actions: {
                                    TextField("Dosya Adı", text: $textFieldValue)
                                    
                                    Button("Kaydet", action: {
                                        convertTextToPDF(text:item.text ?? "hata", fileName: textFieldValue)
                                    })
                                    
                                }, message: {
                                    Text("Lütfen dosya adını giriniz!!")
                                })
                        }
                            
                        }.onDelete(perform: removeItem)
                    }
                }
               else{
                    Text("Dosya Okunmadı")
                        .font(.title)
                }
            }
            .navigationBarItems(trailing: NavigationLink(destination: ImageView(), label: {Image(systemName: "photo")})
            )
                .navigationTitle("Scanner")
                .navigationBarItems(trailing: Button(action: {
                    self.showScannerSheet = true
                }, label: {
                    Image(systemName: "doc.text.viewfinder")
                        .font(.title)
                })
                    .sheet(isPresented: $showScannerSheet, content: {
                        makeScannerView()
                    })
                )
            
            
        }
    }
    func removeItem(at offsets: IndexSet){
        for index in offsets{
            let item = items[index]
            PersistenceController.shared.delete(object: item)
        }
    }

    private func makeScannerView()->ScannerView{
        ScannerView(completion: {
            textPerPage in
            if let outputText = textPerPage?.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines){
                let scanned = Scanned(context: context)
                scanned.text=outputText
                PersistenceController.shared.save()
            let newScanData = ScanData(content: outputText)
                self.texts.append(newScanData)
                self.showScannerSheet = false
             
            }
           
    })
        }

    func convertTextToPDF(text: String, fileName: String) {
        
        let pdfData = text.data(using: .utf8)
         let pdfView = PDFView()
         pdfView.document = PDFDocument(data: pdfData!)
         
         guard let documentsDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        else { fatalError("Destination URL not created")}
        let pdfFileURL = documentsDirectory.appendingPathComponent(fileName).appendingPathExtension("pdf")
         do {
             try pdfData?.write(to: pdfFileURL, options: .atomic)
             
             print("Kaydedildi: \(pdfFileURL)")
         } catch {
             print("Kaydedilirken hata oluştu: \(error)")
             
         }
           
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
