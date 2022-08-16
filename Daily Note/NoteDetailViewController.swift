//
//  NoteDetailViewController.swift
//  Daily Note
//
//  Created by 김원기 on 2022/08/14.
//

import UIKit

protocol NoteDetailViewDelegate: AnyObject {
    func didSelectDelete(indexPath: IndexPath)
}

class NoteDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: NoteDetailViewDelegate?
    
    var note: DailyNote?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    private func configureView() {
        guard let note = self.note else { return }
        self.titleLabel.text = note.title
        self.contentsTextView.text = note.contents
        self.dateLabel.text = dateToString(date: note.date)
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter ()
        formatter.dateFormat = "yy년 MM 월 dd일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    @IBAction func editButton(_ sender: UIButton) {
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        self.delegate?.didSelectDelete(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
