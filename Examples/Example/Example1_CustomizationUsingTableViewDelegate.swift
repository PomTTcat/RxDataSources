//
//  CustomizationUsingTableViewDelegate.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 4/19/16.
//  Copyright © 2016 kzaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator

struct MySection {
    var header: String
    var items: [Item]
}

extension MySection : AnimatableSectionModelType {
    typealias Item = Int
    
    var identity: String {
        return header
    }
    
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}

class CustomizationUsingTableViewDelegate : UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    var dataSource: RxTableViewSectionedAnimatedDataSource<MySection>?
    let dd = BehaviorRelay<[MySection]>(value: [])
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        var decideViewTransition : (TableViewSectionedDataSource<MySection>, UITableView, [Changeset<MySection>]) -> ViewTransition = { (data, tv, change)  in
            
            print("")
            
            // 插入头部N scroll N
            
            // 插入末尾 scroll 到末尾
            
            if change[0].insertedSections.first == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    // your code here
                    tv.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: false)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // your code here
                    tv.scrollToRow(at: IndexPath(row: 0, section: (change[0].finalSections.count - 1)), at: .bottom, animated: true)
                }
            }
            
            return RxDataSources.ViewTransition.reload
            
            
        }
        
        let dataSource = MyDataSource<MySection>(
            decideViewTransition: decideViewTransition,
            configureCell: { ds, tv, _, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "Item \(item)"
                
                return cell
            },
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].header
            }
        )
        
        self.dataSource = dataSource
        
        var sections:[MySection] = [
            MySection(header: "First section", items: [
                1,
                2
            ]),
            MySection(header: "Second section", items: [
                3,
                4
            ]),
            MySection(header: "First section 2", items: [
                5,
                6
            ]),
            MySection(header: "Second section 3", items: [
                7,
                8
            ]),
            MySection(header: "Second section 4", items: [
                9,
                10
            ]),
            MySection(header: "Second section 5", items: [
                11,
                12
            ]),
            MySection(header: "Second section 6", items: [
                13,
                14
            ]),
            MySection(header: "Second section 7", items: [
                15,
                16
            ]),
        ]
        
        dd.accept(sections)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            // your code here
//            sections[2].items.removeAll()
            
            let x = MySection(header: "First section 000", items: [
                21,
                22
            ])
            
            //
//            sections.insert(x, at: 0)
            
            sections.insert(x, at: 4)
            self.dd.accept(sections)
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                // your code here
//                sections[2].items.append(1000)
//                sections[2].items.append(1001)
//                self.dd.accept(sections)
//            }
        }
        
        dd.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

extension CustomizationUsingTableViewDelegate : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.blue
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
}

final class MyDataSource<S: AnimatableSectionModelType>: RxTableViewSectionedAnimatedDataSource<S> {
    private let relay = PublishRelay<Void>()
    var rxRealoded: Signal<Void> {
        return relay.asSignal()
    }
    
    override func tableView(_ tableView: UITableView, observedEvent: Event<[S]>) {
        //Do diff
        //Notify update
        
        var firstTimeLoad = false
        if tableView.numberOfSections == 0 {
            firstTimeLoad = true
        }
        
        super.tableView(tableView, observedEvent: observedEvent)
        print("relay.accept(())")
        relay.accept(())
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
//            // your code here
//            tableView.scrollToRow(at: IndexPath(row: 1, section: 7), at: .bottom, animated: false)
//        }
    }
    
    
}


extension UITableView : SectionedViewType {
  
    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        self.insertRows(at: paths, with: animationStyle)
    }

}
