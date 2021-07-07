//
//  Logic.swift
//  MVVM_Example
//
//  Created by 임정우 on 2021/07/07.
//

import Foundation

/*
Service는 Repository로 부터 Entity를 받아 Model로 변경해준다. JSON -> Date
Repository를 통해 받아온 Entity를 Model로 변경하여 ViewModel에게 전달
Service는 Repository를 통해서 fetch 요청을 해야함 : Repository를 알아야 함

서비스는 현재 모델을 알고있다. (state를 가지고있다.)
 */

class Service {
    
    let repository = Repository()
    
    var currentModel = Model(currentDateTime: Date()) // state
    
    func fetchNow(completion: @escaping (Model) -> Void) {
        
        // Entity -> Model
        repository.fetchNow { [weak self] entity in
            guard let self = self else { return }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyy-MM-dd'T'HH:mm'Z'"
            
            guard let now = formatter.date(from: entity.currentDateTime) else { return }
            
            let model = Model(currentDateTime: now)
            self.currentModel = model
            
            completion(model)
        }
    }
    
    func moveDay(day: Int) {
        guard let movedDay = Calendar.current.date(byAdding: .day,
                                                    value: day,
                                                    to: currentModel.currentDateTime) else { return }
        currentModel.currentDateTime = movedDay
    }
}
