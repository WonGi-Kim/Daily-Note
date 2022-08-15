//
//  ViewController.swift
//  Daily Note
//
//  Created by 김원기 on 2022/08/14.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var CollectionView: UICollectionView!
    
    private var noteList = [DailyNote]() {
        didSet {
            self.saveNoteList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadNoteList()
    }
    
    // noteList에서 추가된 일기를 CollectionView에 표시되도록 구현
    private func configureCollectionView() {
        self.CollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.CollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.CollectionView.delegate = self
        self.CollectionView.dataSource = self
    }
    
    // 일기 작성화면의 이동은 세그웨이를 통해 이동한다
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let writeNoteViewController = segue.destination as? WriteNoteViewController {
            writeNoteViewController.delegate = self
        }
    }
    
    // note인스턴스에 있는 date프로퍼티는 date타입이므로 String으로 형변환
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter ()
        formatter.dateFormat = "yy년 MM 월 dd일 (EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // userDefaults 를 이용하여 앱을 종료해도 사라지지 않도록 구현
    private func saveNoteList() {
        let date = self.noteList.map {
            [
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "noteList")
    }
    
    // userDafaults에 저장된 값을 불러오는 메소드
    private func loadNoteList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "noteList") as? [[String: Any]] else {return}
        self.noteList = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return DailyNote(title: title, contents: contents, date: date, isStar: isStar)
        }
        // 최신순으로 정렬하여 불러오기
        self.noteList = self.noteList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
}

// writeNoteViewCotroller 를 채택해야함
extension ViewController: WriteNoteViewDelegate {
    // 일기 작성화면에서 일기가 등록될때 마다 노트 배열에 등록된 일기가 추가된다
    func didSelectRegister(note: DailyNote) {
        self.noteList.append(note)
        self.CollectionView.reloadData()
        self.noteList = self.noteList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
}

// CollectionView.delegate와 .dataSource를 위해 채택후 필수 메소드 구현
// CollectionView에서 dataSource는 CollectionView로 보여주는 컨텐츠를 관리하는 객체
extension ViewController: UICollectionViewDataSource {
    // 지정된 섹션에 표시할 셀을 묻는 메소드
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.noteList.count
    }
    
    // 컬렉션뷰에 지정된 위치에 표시할 셀을 요청하는 메소드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath) as? NoteCell else { return UICollectionViewCell() }
        let note = self.noteList[indexPath.row]
        cell.titleLabel.text = note.title
        cell.dateLabel.text = self.dateToString(date: note.date)
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    // cell의 사이즈를 표시하는 메소드
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20 , height: 200)
    }
}
