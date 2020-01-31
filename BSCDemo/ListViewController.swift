//
//  ListViewController.swift
//  BSCDemo
//
//  Created by dies irae on 31/01/2020.
//  Copyright © 2020 dies irae. All rights reserved.
//

import Foundation
import UIKit
import Moya
import enum Result.Result
import SwiftMessages

class ListViewController: UITableViewController, RouterType {
    let gateway: NotesGatewayType = NetworkSession.default
    var notes = [Note]()
    let activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .large)
        return activity
    }()

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let item = UIBarButtonItem(barButtonSystemItem: .add,
                                    target: self,
                                    action: #selector(self.addNote))
        navigationItem.rightBarButtonItem = item
        self.view.addSubview(activity)
        activity.center = self.view.center
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = .clear
        self.refreshControl?.tintColor = .black
        self.refreshControl?.addTarget(self,
                                       action: #selector(self.methodPullToRefresh),
                                       for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    func refreshData() {
        self.showProgress(true)
        _ = gateway.request(target: .getList,
                            callbackQueue: .main,
                            progress: nil,
                            completion: { [weak self] (result:Result<[Note], AppError>) in
                                guard let `self` = self else { return }
                                self.showProgress(false)
                                switch result {
                                case .success(let notes):
                                    self.notes = notes
                                    self.tableView.reloadData()
                                    self.refreshControl?.endRefreshing()
                                case .failure(let error):
                                    self.showError(error)
                                }
        })
    }

    // MARK: Actions
    @objc func methodPullToRefresh(sender: AnyObject) {
        self.refreshControl?.beginRefreshing()
        refreshData()
    }

    func showProgress(_ show: Bool) {
        if !show {
            activity.stopAnimating()
        } else {
            activity.startAnimating()
        }
    }

    @objc func addNote(_ sender: Any) {
        let vc = NoteViewController(note: Note(id: -1, title: ""), mode: .create)
        show(vc, sender: nil)
    }

    func open(_ note: Note) {
        let vc = NoteViewController(note: note, mode: .edit)
        show(vc, sender: nil)
    }

    func delete(_ note: Note) {
        self.showProgress(true)
        _ = gateway.request(target: .delete(note),
                            callbackQueue: .main,
                            progress: nil,
                            completion: { [weak self] (result:Result<(), AppError>) in
                                guard let `self` = self else { return }
                                self.showProgress(false)
                                switch result {
                                case .success:
                                    break
                                case .failure(let error):
                                    self.showError(error)
                                }
        })
    }

    // MARK: UITableView Overrides
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "cell")

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = notes[indexPath.row].title
        cell.textLabel?.numberOfLines = 3
        cell.textLabel?.lineBreakMode = .byTruncatingTail
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        open(notes[indexPath.row])
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(notes[indexPath.row])
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension SwiftMessages {
    fileprivate static let notificationsQueue = SwiftMessages()
}

protocol RouterType {
    func showError(_ error: AppError)
    func showSuccess(_ message: String)
    func showProgress(_ show: Bool)
}

extension RouterType {

    func showError(_ error: AppError) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureTheme(.error)
        view.configureDropShadow()
        view.tapHandler = { _ in SwiftMessages.notificationsQueue.hide() }
        view.configureContent(title: "Ooops!",
                              body: error.localizedDescription)
        view.button?.isHidden = true
        view.titleLabel?.numberOfLines = 0
        view.titleLabel?.lineBreakMode = .byWordWrapping
        view.bodyLabel?.numberOfLines = 0
        view.bodyLabel?.lineBreakMode = .byWordWrapping
        view.iconLabel?.numberOfLines = 0
        view.iconLabel?.lineBreakMode = .byWordWrapping
        var config = SwiftMessages.defaultConfig
        config.duration = .seconds(seconds: 5)
        SwiftMessages.notificationsQueue.show(config: config, view: view)
    }

    func showSuccess(_ message: String) {
        let view = MessageView.viewFromNib(layout: .statusLine)
        view.configureTheme(.success)
        view.configureDropShadow()
        view.tapHandler = { _ in SwiftMessages.notificationsQueue.hide() }
        view.configureContent(title: "", body: message)
        view.button?.isHidden = true
        view.titleLabel?.numberOfLines = 0
        view.titleLabel?.lineBreakMode = .byWordWrapping
        view.bodyLabel?.numberOfLines = 0
        view.bodyLabel?.lineBreakMode = .byWordWrapping
        view.iconLabel?.numberOfLines = 0
        view.iconLabel?.lineBreakMode = .byWordWrapping
        var config = SwiftMessages.defaultConfig
        config.duration = .seconds(seconds: 5)
        SwiftMessages.notificationsQueue.show(config: config, view: view)
    }

    func showProgress(_ show: Bool) {

    }

}
