//
//  ItemListViewModel.swift
//  icloudPlayGround
//
//  Created by Lenard Howell on 3/26/23.
//

import Foundation
import CloudKit

enum RecordType: String {
    case itemListing = "ItemListing"
}

class ItemListViewModel: ObservableObject{
    private var database:CKDatabase
    private var container: CKContainer
    
    @Published var items: [ItemViewModel] = []
    
    init(container: CKContainer) {
        self.container = container
        self.database = self.container.publicCloudDatabase
    }

    func deleteitem(_ recordId: CKRecord.ID) {
        
        database.delete(withRecordID: recordId) { deletedRecordId,error in
            if let error  = error {
                print(error)
            } else {
                self.populateItems()
            }
        }
    }

    func saveItem(title: String, price: Decimal){
        let record = CKRecord(recordType: RecordType.itemListing.rawValue)
        let itemlisting = ItemListing(title: title, price: price)
        record.setValuesForKeys(itemlisting.toDictionary())
        
        // Saving record in DataBase
        
        self.database.save(record) { newRecord, error in
            if let error = error {
                print(error)
            } else {
                if let newRecord = newRecord {
                    if let itemListing = ItemListing.fromRecord(newRecord) {
                        DispatchQueue.main.async{
                            self.items.append(ItemViewModel(itemListing: itemListing))
                        }
                    }
                }
            }
        }
    }
    func populateItems() {
        var items: [ItemListing] = []
        let  query = CKQuery(recordType: RecordType.itemListing.rawValue,predicate: NSPredicate(value: true))
        database.fetch(withQuery: query) { result in
            switch result {
            case .success(let result):
                result.matchResults.compactMap{$0.1}
                    .forEach {
                        switch $0 {
                        case .success(let record):
                            if let itemListing = ItemListing.fromRecord(record) {
                                items.append(itemListing)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                DispatchQueue.main.sync{
                    self.items = items.map(ItemViewModel.init)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct ItemViewModel {
    let itemListing: ItemListing
    
    var recordId: CKRecord.ID? {
        itemListing.recordId
    }
    var title: String {
        itemListing.title
    }
    var price: Decimal {
        itemListing.price
    }
    
}
