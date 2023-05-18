//
//  ViewController.swift
//  HW_BMR_Calculator
//
//  Created by 曹家瑋 on 2023/5/16.
//

/*
 ● 男性：基礎代謝率 = (10 × 公斤體重) + (6.25 × 公分身高) - (5 × 年齡歲數) + 5
 ● 女性：基礎代謝率 = (10 × 公斤體重) + (6.25 × 公分身高) - (5 × 年齡歲數) – 161
 */

/*
 1.久坐
 沒啥運動><
 TDEE = 1.2 x BMR
 2.輕量活動
 每周運動1-3天
 TDEE = 1.375 x BMR
 3.中度活動量
 每周運動3-5天
 TDEE = 1.55 x BMR
 4.高度活動量
 每周運動6-7天
 TDEE = 1.725 x BMR
 5.非常高度活動量
 無時無刻都在運動XD
 TDEE = 1.9 x BMR */

/* 1. 先區分出男性、女性
   2. 並且先計算個別BMR。
   3. 再用 BRM 計算 TDEE */

import UIKit

class ViewController: UIViewController {
    
    // 性別選項
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    // 身高輸入: cm
    @IBOutlet weak var heightInputField: UITextField!
    // 體重輸入: kg
    @IBOutlet weak var weightInputField: UITextField!
    // 年齡輸入
    @IBOutlet weak var ageInputField: UITextField!
    // 運動頻率
    @IBOutlet weak var activityLevelLabel: UILabel!
    // 存儲運動頻率 Slider 的值 (TDEE 才會用到)
    @IBOutlet weak var exerciseSlider: UISlider!
    // BMR 計算結果顯示
    @IBOutlet weak var bmrResultLabel: UILabel!
    // TDEE 計算結果顯示
    @IBOutlet weak var tdeeResultLabel: UILabel!
    
    // 運動頻率 Array
    let exerciseFrequencyArrays = ["Sedentary or No Exercise", "Exercise 1-3 Times / Week", "Intense Exercise 3-4 Times / Week", "Intense Exercise 6-7 Times / Week", "Very Intense Exercise Daily!"]
    
    // 在view載入後執行的初始化操作
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // exerciseSlider 的最大值最小值、起始值
        exerciseSlider.minimumValue = 0
        exerciseSlider.maximumValue = 4
        exerciseSlider.value = 0
    }

    // 運動頻率Slider：
    @IBAction func exerciseFrequencySliderChanged(_ sender: UISlider) {
        
        // rounded() 四捨五入 sender.value
        let sliderValue = sender.value.rounded()
        // 將 sliderValue 轉換為整數並設置回 exerciseSlider，確保滑動條的值一直保持在整數。
        exerciseSlider.setValue(sliderValue, animated: false)
                
        /* 使用 sliderValue 作為索引，從 exerciseFrequencyArrays 中取出對應的運動頻率字串，並將其設置為 activityLevelLabel 的文字。實現當 Slider 滑動時，更新運動頻率文字的顯示。 */
        activityLevelLabel.text = exerciseFrequencyArrays[Int(sliderValue)]
    }
    
    // 計算Button：BMR、TDEE
    @IBAction func calculateButtonTapped(_ sender: UIButton) {
        
        // 將 UITextField 的 text 屬性的值指派給相應的變數。保證這些 Optional的值 不是nil，以確保它們的值存在。
        // TextField 的 text 也是optional， 但會有值（空字串），一定有東西。可以放心加！。
        let heightText = heightInputField.text!
        let weightText = weightInputField.text!
        let ageText = ageInputField.text!
        
        // 字串轉數字用於計算
        let height = Double(heightText)
        let weight = Double(weightText)
        let age = Double(ageText)
        
        // 將 exerciseSlider 的值轉換為整數，作為運動頻率的索引值。並且用在 if else 條件判斷 TDEE 計算使用。（因為女性也會用到)
        let exerciseFrequencyIndex = Int(exerciseSlider.value)
        
        // 計算BMR之前，先檢查 height、weight 和age 是否為 nil，如果有值（不為nil）則進行計算，selectedSegmentIndex == 0 為男性
        if height != nil, weight != nil, age != nil, genderSegmentedControl.selectedSegmentIndex == 0 {

            /*  基礎代謝：先前條件為不等於 nil 則進行計算。在此已經確認身高體重年紀皆有值，因此要加入"！"，將Optional進行解包，將它們的值指派給 非Optional 的變數*/
            
            // ● 男性：基礎代謝率 = (10 × 公斤體重) + (6.25 × 公分身高) - (5 × 年齡歲數) + 5
            let bmrCalculate = (10 * weight!) + (6.25 * height!) - (5 * age!) + 5
            // BMR 數值取小數點第一位，並顯示於 bmrResultLabel 上
            bmrResultLabel.text = String(format: "%.1f", bmrCalculate)
            
            // 根據選定的 運動頻率索引值 和 前面計算得到的 BMR，調用 calculateTdee function 計算 TDEE。
            let tdee = calculateTdee(bmr: bmrCalculate, frequencyIndex: exerciseFrequencyIndex)
            // 將結果設置到 tdeeResultLabel 中。
            tdeeResultLabel.text = String(format: "%.1f", tdee)
            
        // selectedSegmentIndex == 1 為女性
        } else if height != nil, weight != nil, age != nil, genderSegmentedControl.selectedSegmentIndex == 1 {

            // ● 女性：基礎代謝率 = (10 × 公斤體重) + (6.25 × 公分身高) - (5 × 年齡歲數) – 161
            let bmrCalculate = (10 * weight!) + (6.25 * height!) - (5 * age!) - 161
            bmrResultLabel.text = String(format: "%.1f", bmrCalculate)
            
            let tdee = calculateTdee(bmr: bmrCalculate, frequencyIndex: exerciseFrequencyIndex)
            tdeeResultLabel.text = String(format: "%.1f", tdee)
        }
        // 點擊計算Button時，會將鍵盤收起
        view.endEditing(true)
    }
    
    // 重置 Button
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        
        // Segmented Control 回到 男性欄位
        genderSegmentedControl.selectedSegmentIndex = 0
        
        // 身高、體重、年紀 TextTield 空字串。
        heightInputField.text = ""
        weightInputField.text = ""
        ageInputField.text = ""
        
        // 運動頻率Slider 的值回到初始0
        exerciseSlider.value = 0
        
        // 計算結果空字串
        bmrResultLabel.text = "0"
        tdeeResultLabel.text = "0"
        
        // 收起鍵盤
        view.endEditing(true)
    }
    
}

/*function設置(TDEE計算方式）
因為不管男性還是女性，只有在BMR的計算才會有公式上的差異，而TDEE則會依照不同運動頻率來做計算。此外她們分屬不同的{}括弧裡，因此在命名上並不會互相影響，都是在各自獨立的括弧裡進行運算。
此外，calculateTedd 方法的兩個參數：bmr 是之前計算得到的 BMR 值，exerciseFrequencyIndex 是選定的運動頻率索引值。*/
func calculateTdee(bmr:Double, frequencyIndex: Int) -> Double{
    
    // 先宣告一個變數來存儲計算得到的 TDEE 值。
    var tdee: Double = 0.0
    
    // 根據運動頻率的 Slider 的值，來決定該條件下所使用的 TDEE計算公式
    if frequencyIndex == 0 {
        // 沒運動習慣：TDEE = 1.2 x BMR
        tdee = 1.2 * bmr
        
    } else if frequencyIndex == 1 {
        // 輕量活動(每周運動1-3天)：TDEE = 1.375 x BMR
        tdee = 1.375 * bmr
        
    } else if frequencyIndex == 2 {
        // 中度活動量(每周運動3-5天)：TDEE = 1.55 x BMR
        tdee = 1.55 * bmr
        
    } else if frequencyIndex == 3 {
        // 高度活動量(每周運動6-7天)：TDEE = 1.725 x BMR
        tdee = 1.725 * bmr
        
    } else if frequencyIndex == 4 {
        // 非常高度活動量(無時無刻都在運動)：TDEE = 1.9 x BMR
        tdee = 1.9 * bmr
    }
    // 返回計算得到的 TDEE 值
    return tdee
}

// 原先還未使用 function 的程式碼
//// 當Slider的值 == 0 時，代表沒有運動習慣時，該條件下所使用的 TDEE計算公式
//if exerciseFrequencyIndex == 0 {
//
//    // 沒運動習慣：TDEE = 1.2 x BMR
//    let tdee = bmrCalculate * 1.2
//    // 數字轉字串： TDEE 數值取小數點第一位，並顯示於 tdeeResultLabel 上
//    tdeeResultLabel.text = String(format: "%.1f", tdee)
//
//} else if exerciseFrequencyIndex == 1 {
//
//    // 輕量活動(每周運動1-3天)：TDEE = 1.375 x BMR
//    let tdee = bmrCalculate * 1.375
//    tdeeResultLabel.text = String(format: "%.1f", tdee)
//
//} else if exerciseFrequencyIndex == 2 {
//
//   // 中度活動量(每周運動3-5天)：TDEE = 1.55 x BMR
//    let tdee = bmrCalculate * 1.55
//    tdeeResultLabel.text = String(format: "%.1f", tdee)
//
//} else if exerciseFrequencyIndex == 3 {
//
//    // 高度活動量(每周運動6-7天)：TDEE = 1.725 x BMR
//    let tdee = bmrCalculate * 1.725
//    tdeeResultLabel.text = String(format: "%.1f", tdee)
//
//} else if exerciseFrequencyIndex == 4 {
//
//    // 非常高度活動量(無時無刻都在運動)：TDEE = 1.9 x BMR
//    let tdee = bmrCalculate * 1.9
//    tdeeResultLabel.text = String(format: "%.1f", tdee)
//}
