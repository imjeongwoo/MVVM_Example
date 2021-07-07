//
//  Repository.swift
//  MVVM_Example
//
//  Created by 임정우 on 2021/07/07.
//

import Foundation

/*
Repository는 서버에서 Entity(UtcTimeModel)을 받아온다.
그리고 Service에게 전달한다.
*/

class Repository {
    func fetchNow(completion: @escaping (UtcTimeModel) -> Void) {
        let url = "http://worldclockapi.com/api/json/utc/now"
        
        URLSession.shared.dataTask(with: URL(string: url)!) { data, _, _ in
            guard let data = data else { return }
            guard let model = try? JSONDecoder().decode(UtcTimeModel.self, from: data) else { return }
            
            completion(model)
        }.resume()
    }
}
