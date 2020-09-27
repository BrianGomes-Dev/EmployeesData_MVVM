//
//  Networking.swift
//  EmployeesData_MVVM
//
//  Created by user172197 on 9/27/20.
//

import Foundation

class Networking :  NSObject {
    
    private let sourcesURL = URL(string: "http://dummy.restapiexample.com/api/v1/employees")!
    
    func apiToGetEmployeeData(completion : @escaping (Employees) -> ()){
        URLSession.shared.dataTask(with: sourcesURL) { (data, urlResponse, error) in
            if let data = data {
                
                let jsonDecoder = JSONDecoder()
                
                let empData = try! jsonDecoder.decode(Employees.self, from: data)
                    completion(empData)
            }
        }.resume()
    }
}
