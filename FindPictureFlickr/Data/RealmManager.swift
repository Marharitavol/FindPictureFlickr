//
//  RealmManager.swift
//  FindPictureFlickr
//
//  Created by Rita on 17.01.2022.
//

import Foundation
import RealmSwift

class RealmManager {
    func saveHistory(_ history: RealmModel) {
        do {
            let localRealm = try Realm()
            try localRealm.write {
                localRealm.add(history)
            }
        } catch {
            print("save Error")
        }
    }
    
    func deletePicture(_ model: RealmModel) {
        do {
            let localRealm = try Realm()
            try! localRealm.write {
                //localRealm.delete(model)
                localRealm.delete(localRealm.objects(RealmModel.self).filter {$0.urlImage == model.urlImage})
            }
        } catch {
            print("deleting Error")
        }
    }
    
    func fetchHistory(completion: @escaping (_ historyArray: [RealmModel]?) -> Void) {
        do {
            let localRealm = try Realm()
            let historyResults = localRealm.objects(RealmModel.self)
            completion(Array(historyResults))
        } catch {
            print("fetchHistory error")
        }
    }
}


