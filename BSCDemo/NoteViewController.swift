//
//  NoteViewController.swift
//  BSCDemo
//
//  Created by dies irae on 31/01/2020.
//  Copyright © 2020 dies irae. All rights reserved.
//

import Foundation
import UIKit
import enum Result.Result
import Moya

enum NoteMode {
    case
    create,
    edit
}

class NoteViewController: UIViewController, RouterType {

    let gateway: NotesGatewayType = NetworkSession.default
    let activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .large)
        return activity
    }()
    let textView: UITextView = {
        UITextView()
    }()
    lazy var actionItem: UIBarButtonItem = {
        switch self.mode {
        case .create:
            return UIBarButtonItem(barButtonSystemItem: .save,
                                   target: self,
                                   action: #selector(self.create))
        case .edit:
            return UIBarButtonItem(barButtonSystemItem: .save,
                                   target: self,
                                   action: #selector(self.save))
        }
    }()

    var note: Note
    let mode: NoteMode
    init(note: Note, mode: NoteMode) {
        self.note = note
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: Lifecycle
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.keyboardDismissMode = .interactive
        self.textView.text = note.title
        self.view.addSubview(textView)
        self.textView.frame = self.view.bounds
        self.textView.delegate = self
        self.view.addSubview(activity)
        activity.center = self.view.center
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    // MARK: Actioons
    func refreshData() {
        switch self.mode {
        case .create:
            break
        case .edit:
            self.showProgress(true)
            _ = gateway.request(target: .detail(note),
                                callbackQueue: .main,
                                progress: nil,
                                completion: { [weak self] (result:Result<Note, AppError>) in
                                    guard let `self` = self else { return }
                                    self.showProgress(false)
                                    switch result {
                                    case .success(let note):
                                        self.note = note
                                        self.textView.text = note.title
                                    case .failure(let error):
                                        self.showError(error)
                                    }
            })

        }
    }


    @objc func save(_ sender: Any) {
        let note = Note(id: self.note.id, title: textView.text)
        self.showProgress(true)
        _ = gateway.request(target: .update(note),
                            callbackQueue: .main,
                            progress: nil,
                            completion: { [weak self] (result: Result<Note, AppError> ) in
                                guard let `self` = self else { return }
                                self.showProgress(false)
                                switch result {
                                case .success(let note):
                                    self.showSuccess("\(note)")
                                case .failure(let error):
                                    self.showError(error)
                                }
        })

    }

    @objc func create(_ sender: Any) {
        let note = Note(id: -1, title: textView.text)
        showProgress(true)
        _ = gateway.request(target: .create(note),
                            callbackQueue: .main,
                            progress: nil,
                            completion: { [weak self] (result: Result<Note, AppError> ) in
                                guard let `self` = self else { return }
                                self.showProgress(false)
                                switch result {
                                case .success(let note):
                                    self.showSuccess("\(note)")
                                case .failure(let error):
                                    self.showError(error)
                                }
        })
    }

    func showProgress(_ show: Bool) {
        if !show {
            activity.stopAnimating()
        } else {
            activity.startAnimating()
        }
    }

}

extension NoteViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        if textView.text == note.title {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = actionItem
        }
    }
}
