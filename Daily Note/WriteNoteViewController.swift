//
//  WriteNoteViewController.swift
//  Daily Note
//
//  Created by 김원기 on 2022/08/14.
//

import UIKit

// delegate를 통해서 일기장 리스트 화면에 일기가 작성된 노트 객체를 전달
protocol WriteNoteViewDelegate: AnyObject {
    func didSelectRegister(note: DailyNote)
}

class WriteNoteViewController: UIViewController {

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    // 노트를 작성할때 날짜 부분에서 키보드가 아닌 데이터피커로 날짜 설정하기 위한 프로퍼티
    private let datePicker = UIDatePicker()
    // 데이트 피커에서 설정된 데이트를 저장하는 프로퍼티
    private var noteDate: Date?
    weak var delegate: WriteNoteViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.confirmButton.isEnabled = false
    }
    
    // 일기를 쓰는 UITextView의 테두리를 설정하는 함수
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        self.contentsTextView.layer.borderColor = borderColor.cgColor // layer관련 컬러는 cg컬러로 작성해야한다.
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }
    
    //
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        // addTarget메소드는 UIController객체가 이벤트에 응답하는 방식을 설정하는 메소드
        // 액션에는 이벤트가 발생했을때 이에 응답하여 호출될 메소드를 셀렉터를 이용해 전달
        // for 어떤 이벤트가 일어났을때 액션에 정의한 메소드를 호출할지 결정
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.datePicker.locale = Locale(identifier: "ko-KR") // 아이폰에서는 코드없이 한국식으로 표기 되지만 맥에서 빌드시 달라짐
        self.dateTextField.inputView = self.datePicker
    }
    
    private func configureInputField() {
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @IBAction func confirmButton(_ sender: UIBarButtonItem) {
        // 일기를 작성하고 등록버튼을 눌렀을 때 노트 객체를 생성하고 delegate에 정의한 didselectregister 메소드를 호출하여
        // 메소드 파라미터에 생성된 노트 객체를 전달
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.noteDate else { return }
        let note = DailyNote(title: title, contents: contents, date: date, isStar: false)
        self.delegate?.didSelectRegister(note: note)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func datePickerValueDidChange(_ dataPicker: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 년 MM 월 dd 일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        self.noteDate = datePicker.date
        self.dateTextField.text = formatter.string(from: datePicker.date)
        self.dateTextField.sendActions(for: .editingChanged)
    }
    
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    // 유저가 화면을 터치하면 발생하는 메소드로 화면 터치시 키보드 혹은 데이터피커 같은 도구가 내려간다.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // 아래 조건이 맞으면 등록 버튼이 활성화 되도록하는 함수
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !(self.contentsTextView.text.isEmpty)
    }
    
}

extension WriteNoteViewController: UITextViewDelegate {
    // 이 메소드는 텍스트뷰에 텍스트가 입력될때마다 호출
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
