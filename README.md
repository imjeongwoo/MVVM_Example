
# MVVM에서는 3가지 형태의 Model이 존재한다.

+ 서버로부터 받은 원천데이터 : `Entity`

+ 비지니스 로직에서 사용하는 근본 데이터 : `Model`

+ 화면에 보이기 위한 화면 데이터  : `ViewModel`

<br>

##  프로그램이 화면 `View`와 비지니스 로직인 `Service`로 구성된다고 보자!

+ 가장 중요한 부분은 비지니스 로직인 `Service`
+ `Service`에서 취급하는 데이터가 `Model`이다
+ 이 모델은 원천 데이터 `Entity`로 부터 나왔다.
+ `Entity`를 가져오는 역할을 하는 것은 `Repository`
+ 사용자에게 보여질 화면인 `View`는 `Service`가 처리한 데이터 `Model`을 그려낸다
+ `Model`을 그대로 그려낼 수 없기 때문에 **화면용 데이터**로 변환이 필요
+ 화면용 데이터가 `View`를 위한 `Model`인 `ViewModel`이다


<br>

## **Entity**
> 서버 또는 DB로 부터 전달된 **원천 데이터**이다.  
`Entity`를 가져오는 역할을 하는 것이 `Repository`이다.
```swift
// Entity.swift
struct UtcTimeModel: Codable {
    let id: String
    let currentDateTime: String
    let utcOffset: String
    let isDayLightSavingsTime: Bool
    let dayOfTheWeek: String
    let timeZoneName: String
    let currentFileTime: Int
    let ordinalDate: String
    let serviceResponse: String?

    enum CodingKeys: String, CodingKey {
        case id = "$id"
        case currentDateTime
        case utcOffset
        case isDayLightSavingsTime
        case dayOfTheWeek
        case timeZoneName
        case currentFileTime
        case ordinalDate
        case serviceResponse
    }
}
```

<br>

## **Repository**
> `Repository`는 서버 또는 DB에서 `Entity`(UtcTimeModel)을 받아온다.  
그리고 받아온 것을 `Service`에게 전달한다.

```swift
// Repository.swift
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
```
<br>

## **Model**
> 실제 비지니스 로직에서 사용하는 근본 데이터 `Model`  
`Service`에 의해서 `Entity`가 `Model`로 변경된다.

```swift
struct Model {
    var currentDateTime: Date
}
```
<br>

## **Service**
> `Repository`를 통해 받아온 `Entity`를 `Model`로 변경하여 `ViewModel`에게 전달  
`Service`는 `Repository`를 통해서 fetch 요청을 해야함 : `Repository`를 알고 있어야한다.

```swift
// Service.swift
// 서비스는 현재 모델을 알고있음 (state를 갖고있다)
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
```

<br>

## **ViewModel**
> `ViewModel`은 `Service`가 전달해준 `Model`을 `ViewModel`로 변환  
`ViewModel`은 `Service`로 부터 받아온다 : `Service`를 알고있어야함  
`View`에 보여질 `ViewModel`을 갖고 있고 `View`를 알아야 할 필요가 없음
 
```swift
//  ViewModel.swift
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
```

<br>

## **View**
> `View` 입장에서는 `View`에 보여져야할 모든 데이터 형태가 `ViewModel`에 있기때문에 `ViewModel`만 바라본다!  
`View`에서 Event가 발생했을 때 그 Event에 관한 적절한 처리도 `ViewModel`에게 요청한다!!

```swift
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
```
