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
    
    // 수정 버튼을 누르면 일기 작성 뷰컨트롤러로 이동한다.
    @IBAction func editButton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: "WriteNoteViewController") as? WriteNoteViewController else { return }
        guard let indexPath = indexPath else { return }
        guard let note = self.note else { return }
        viewController.noteEditorMode = .edit(indexPath, note)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editNoteNotification(_:)),
            name: NSNotification.Name("editNote"),
            object: nil
        )
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        guard let indexPath = self.indexPath else { return }
        self.delegate?.didSelectDelete(indexPath: indexPath)
        self.navigationController?.popViewController(animated: true)
    }
         
    @objc func editNoteNotification(_ notification: Notification) {
        guard let note = notification.object as? DailyNote else { return }
        guard let row = notification.userInfo?["indexPath.row"] as? Int else { return }
        self.note = note
        self.configureView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
}
