//
//  ImageView.swift
//  Scanner
//
//  Created by BERKAN NALBANT on 1.02.2023.
//

import SwiftUI
import Vision

struct ImageView: View {
    
    @State private var postImage: Image?
    @State private var pickedImage: Image?
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var imageData: Data = Data()
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var error: String = ""
    @State private var showingAlert = false
    @State private var alertTitle:String = "Oh No 😢😢"
    @State private var text = ""
    
    @Environment(\.managedObjectContext) var context
    
    @FetchRequest(entity: Scanned.entity(), sortDescriptors:[NSSortDescriptor(keyPath:\Scanned.text, ascending: true)]) var items: FetchedResults<Scanned>

    func loadImage(){
        guard let inputImage = pickedImage else{return}
        postImage = inputImage
    }
    

    private func textRecognize(image:UIImage?){
       
       guard let cgImage = image?.cgImage else{return}
       
       let handler = VNImageRequestHandler(cgImage: cgImage,options: [:])
       
       let request = VNRecognizeTextRequest { request, error in
           guard let observations = request.results as? [VNRecognizedTextObservation],
                 error == nil else{return}
           let text = observations.compactMap({
               $0.topCandidates(1).first?.string
           }).joined(separator: ", ")
           let scanned = Scanned(context: context)
           scanned.text=text
           PersistenceController.shared.save()
       }
       do{
           try handler.perform([request])
       }catch{
           print(error)
       }

   }

    var body: some View {
        
        VStack{
           
            VStack{
                if postImage != nil{
                    postImage!.resizable()
                        .frame(width: 300, height: 200)
                        .onTapGesture {
                            self.showActionSheet = true
                        }
                }else{
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 300, height: 200)
                        .foregroundColor(.blue)
                            .onTapGesture {
                                self.showActionSheet = true
                            }
                }
            }
            Spacer()
            
            let uiImage: UIImage = postImage.asUIImage() 
            Button(action: {textRecognize(image: uiImage)}){
                Text("Çevir").font(.title).modifier(ButtonModifier())
            }.alert(isPresented: $showingAlert){
                Alert(title: Text(alertTitle), message: Text(error), dismissButton: .default(Text("Tamam")))
            }
        }.padding()
        .sheet(isPresented: $showImagePicker,onDismiss: loadImage){
            ImagePicker(pickedImage: self.$pickedImage, showImagePicker: self.$showImagePicker, imageDate: self.$imageData)
        }.actionSheet(isPresented: $showActionSheet){
            ActionSheet(title: Text(""),buttons: [.default(Text("Fotoğraf seç")){
                self.sourceType = .photoLibrary
                self.showImagePicker = true
            },.cancel()])
        }
    }
}


struct imgeView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
