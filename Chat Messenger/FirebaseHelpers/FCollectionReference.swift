//
//  FCollectionReference.swift
//  Chat Messenger
//
//  Created by manukant tyagi on 08/06/22.
//

import Foundation
import FirebaseFirestore
enum FcollectionReference: String{
    case User
    case Recent
}
func FirebaseReference(_ collectionReference: FcollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
