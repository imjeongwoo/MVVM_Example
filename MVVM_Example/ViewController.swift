//
//  ViewController.swift
//  MVVM_Example
//
//  Created by 임정우 on 2021/07/07.
//

import UIKit

/*
 View 입장에서는 View에 보여져야할 모든 데이터 형태가 ViewModel에 있기때문에 ViewModel만 바라본다!
 
 View에서 Event가 발생했을 때 그 Event에 관한 적절한 처리도 ViewModel에게 요청한다
 */

class ViewController: UIViewController {
    
    @IBOutlet weak var datetimeLabel: UILabel!
    
    @IBAction func onYesterday() {
        viewModel.moveDay(day: -1)
    }
    
    @IBAction func onNow() {
        datetimeLabel.text = "Loading.."
        viewModel.reload()
    }
    
    @IBAction func onTomorrow() {
        viewModel.moveDay(day: 1)
    }
    
    let viewModel = ViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 뷰 모델에 fetch 해오기
        viewModel.onUpdated = { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.datetimeLabel.text = self.viewModel.dateTimeString
            }
        }
        
        viewModel.reload()
        
        // ViewModel이 View를 setting하는 부분
    }
}
