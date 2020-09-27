//
//  EmployeesViewModel.swift
//  EmployeesData_MVVM
//
//  Created by user172197 on 9/27/20.
//

import Foundation

class EmployeesViewModel : NSObject {
    
    private var networking : Networking!
    private(set) var empData : Employees! {
        didSet {
            self.bindEmployeeViewModelToController()
        }
    }
    
    var bindEmployeeViewModelToController : (() -> ()) = {}
    
    override init() {
        super.init()
        self.networking =  Networking()
        callFuncToGetEmpData()
    }
    
    func callFuncToGetEmpData() {
        self.networking.apiToGetEmployeeData { (empData) in
            self.empData = empData
        }
    }
}
