import NSObject_Rx
import RIBs
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

protocol PresentableListener: AnyObject {
    var didSelectAlbumRelay: BehaviorRelay<ViewModel.Album?> { get }
}

final class ViewController: UIViewController, Presentable, ViewControllable {
    weak var listener: PresentableListener?

    lazy var relay = BehaviorRelay<ViewModel>(value: .empty)

    override func loadView() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 12, left: 4, bottom: 0, right: 4)
        view = collectionView
        setupBindings(collectionView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    func push(_ viewControllable: RIBs.ViewControllable) {
        let viewController = viewControllable.uiviewController
        navigationController?.pushViewController(viewController, animated: true)
    }

    private lazy var dataSource = RxCollectionViewSectionedAnimatedDataSource<ViewModel.Section>(
        configureCell: { [weak self] in
            guard let self = self else { fatalError("self must not be nil") }
            return self.configureCell(dataSource: $0, collectionView: $1, indexPath: $2, model: $3)
        }
    )
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width
        let side = availableWidth / 2
        return CGSize(width: side, height: side)
    }
}

private extension ViewController {
    func setupBindings(_ customView: UICollectionView) {
        customView.rx.setDelegate(self).disposed(by: rx.disposeBag)

        relay.map { $0.sections }
            .bind(to: customView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)

        customView.rx
            .modelSelected(ViewModel.Album.self)
            .bind(
                onNext: { [weak listener] row in
                    listener?.didSelectAlbumRelay.accept(row)
                }
            ).disposed(by: rx.disposeBag)
    }

    func configureCell(
        dataSource _: CollectionViewSectionedDataSource<ViewModel.Section>,
        collectionView: UICollectionView,
        indexPath: IndexPath,
        model: ViewModel.Album
    ) -> UICollectionViewCell {
        collectionView.register(AlbumCell.self, forCellWithReuseIdentifier: "\(AlbumCell.self)")

        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "\(AlbumCell.self)",
                for: indexPath
            ) as? AlbumCell
        else { fatalError("unexpected cell type") }

        cell.configure(with: model)

        return cell
    }
}
