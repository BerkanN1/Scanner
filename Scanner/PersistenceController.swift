//
//  PersistenceController.swift
//  Scanner
//
//  Created by BERKAN NALBANT on 29.01.2023.
//

import CoreData

struct PersistenceController{
    
    static let shared = PersistenceController()
    let conteiner : NSPersistentContainer
    
    init(){
        conteiner = NSPersistentContainer(name: "Stash")
        conteiner.loadPersistentStores { description, error in
            
            if let error = error{
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func save(completion: @escaping (Error?) ->() = {_ in}){
        
        let context = conteiner.viewContext
        if context.hasChanges{
            
            do{
                try context.save()
                completion(nil)
            }catch{
                completion(error)
            }
            
        }
        
    }
    
    func delete(object:NSManagedObject,completion: @escaping (Error?) ->() = {_ in}){
        let context = conteiner.viewContext
        context.delete(object)
        save(completion: completion)
    }
}

