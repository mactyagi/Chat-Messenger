//
//  GlobalFunction.swift
//  Chat Messenger
//
//  Created by manukant tyagi on 12/06/22.
//

import Foundation


func fileNameFrom(fileUrl: String) -> String{
    return  fileUrl.components(separatedBy: "_").last!.components(separatedBy: "?").first!.components(separatedBy: ".").first!
}
