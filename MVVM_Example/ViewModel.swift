//
//  ViewModel.swift
//  MVVM_Example
//
//  Created by 임정우 on 2021/07/07.
//

import Foundation

/*
 ViewModel은 Service로 부터 받아온다 : Service를 알고있어야함
 ViewModel은 Service가 전달해준 Model을 ViewModel으로 변환. Date -> String
 
 */

class ViewModel {
    var onUpdated: () -> Void = {}
    
    var dateTimeString: String = "Loading.." // 화면에 보여져야할 값 : View를 위한 Model
    {
        didSet { // View를 위한 Model이 바뀔때 호출 -> 화면에 보여져야할 값이 바뀐다 (onUpdated)
            onUpdated()
        }
    }
    let service = Service()
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy년 MM월 dd일 HH시 mm분"
        return formatter.string(from: date)
    }
    
    func reload() {
    // Model -> ViewModel
        service.fetchNow { [weak self] model in
            guard let self = self else { return }
            let dateString = self.dateToString(date: model.currentDateTime)
            self.dateTimeString = dateString
        }
    }
    
    // View의 Event에 관한 적절한 처리를 ViewModel에서 직접 처리하는 것이 아니라 Service에서 일어난다.
    // Service가 실제 앱의 핵심 비지니스 로직이기 때문임
    func moveDay(day: Int) {
        service.moveDay(day: day)
        dateTimeString = dateToString(date: service.currentModel.currentDateTime)
    }
}
