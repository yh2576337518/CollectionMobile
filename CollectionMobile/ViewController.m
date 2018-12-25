//
//  ViewController.m
//  CollectionMobile
//
//  Created by 惠上科技 on 2018/12/24.
//  Copyright © 2018 惠上科技. All rights reserved.
//

#import "ViewController.h"

#import "CollectionViewCell.h"

#import "ImageTableViewCell.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDropDelegate,UICollectionViewDragDelegate,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,UITableViewDragDelegate,UITableViewDropDelegate>
//collectionView
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

//tableView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;


/** 记录拖拽的 indexPath */
@property (nonatomic, strong) NSIndexPath *dragIndexPath;

@end

static NSString *const cellIdentifier = @"cellIdentifier";
static NSString *const identifier = @"kDragCellIdentifier";
static NSString *kItemForTypeIdentifier = @"kItemForTypeIdentifier";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //collectionView 拖拽
//    [self addCollectionView];
    
    //tableView 拖拽
    [self addTableView];
    
}

#pragma mark ================   tableViewDragView   ===============
-(void)addTableView{
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[ImageTableViewCell class] forCellReuseIdentifier:identifier];
    self.tableView.dragInteractionEnabled = YES;
    self.tableView.dropDelegate = self;
    self.tableView.dragDelegate = self;
}

#pragma mark -------Setters && Getters
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorInset = UIEdgeInsetsZero;
        _tableView.rowHeight = 250;
    }
    return _tableView;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        NSMutableArray *tempArray = [@[] mutableCopy];
        for (NSInteger i = 0; i <= 5; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"image%ld",i]];
            [tempArray addObject:image];
        }
        _dataSource = tempArray;
    }
    return _dataSource;
}

#pragma mark ------UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.numberOfLines = 0;
    cell.targetImageView.image = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark ------UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(nonnull NSIndexPath *)indexPath withContext:(nonnull id<UISpringLoadedInteractionContext>)context{
    return YES;
}

#pragma mark ----------UITableViewDragDelegate

/**
 开始拖拽 添加了 UIDragInteraction 的控件 会调用这个方法，从而获取可供拖拽的 item
 如果返回 nil，则不会发生任何拖拽事件
 */
- (nonnull NSArray<UIDragItem *> *)tableView:(nonnull UITableView *)tableView itemsForBeginningDragSession:(nonnull id<UIDragSession>)session atIndexPath:(nonnull NSIndexPath *)indexPath{
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.row]];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
//    self.dragIndexPath = indexPath;
    return @[item];
}


/**
 当接收到添加item响应时，会调用该方法向已经存在的drag会话总添加item
 如果需要，可以使用提供的点（在集合视图的坐标空间中） 进行其他命中测试
 如果该方法未实现，或返回空数组，则不会将任何 item 添加到拖动，手势也会正常的响应
 */
- (NSArray<UIDragItem *> *)tableView:(UITableView *)tableView itemsForAddingToDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point{
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:self.dataSource[indexPath.row]];
    UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    return @[item];
}

- (nullable UIDragPreviewParameters *)tableView:(UITableView *)tableView dragPreviewParametersForRowAtIndexPath:(NSIndexPath *)indexPath{
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    CGRect rect = CGRectMake(0, 0, tableView.bounds.size.width, tableView.rowHeight);
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:15];
    return parameters;
}

#pragma mark --------UITableViewDropDelegate
//当用户开始初始化 drop 手势的时候会调用该方法
- (void)tableView:(UITableView *)tableView performDropWithCoordinator:(id<UITableViewDropCoordinator>)coordinator{
    NSIndexPath *destinationindexPath = coordinator.destinationIndexPath;
    
//    //如果开始拖拽的 indexPath 和 要释放的目标 indexPath 一致，就不做处理
//    if (self.dragIndexPath.section == destinationindexPath.section && self.dragIndexPath.row == destinationindexPath.row) {
//        return;
//    }
//    [tableView performBatchUpdates:^{
//        // 目标 cell 换位置
//        id obj = self.dataSource[self.dragIndexPath.row];
//        [self.dataSource removeObjectAtIndex:self.dragIndexPath.row];
//        [self.dataSource insertObject:obj atIndex:destinationindexPath.row];
//        [tableView deleteRowsAtIndexPaths:@[self.dragIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [tableView insertRowsAtIndexPaths:@[destinationindexPath] withRowAnimation:UITableViewRowAnimationFade];
//    } completion:nil];


    if (coordinator.items.count == 1 && coordinator.items.firstObject.sourceIndexPath) {
        [tableView performBatchUpdates:^{
            NSIndexPath *sourceIndexPath = coordinator.items.firstObject.sourceIndexPath;
            //目标 cell 换位置
            id obj = self.dataSource[sourceIndexPath.row];
            [self.dataSource removeObjectAtIndex:sourceIndexPath.item];
            [self.dataSource insertObject:obj atIndex:destinationindexPath.item];
            [tableView deleteRowsAtIndexPaths:@[sourceIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[destinationindexPath] withRowAnimation:UITableViewRowAnimationFade];
        } completion:nil];
    }
}

// 该方法是提供释放方案的方法，虽然是optional，但是最好实现
// 当 跟踪 drop 行为在 tableView 空间坐标区域内部时会频繁调用
// 当drop手势在某个section末端的时候，传递的目标索引路径还不存在（此时 indexPath 等于 该 section 的行数），这时候会追加到该section 的末尾
// 在某些情况下，目标索引路径可能为空（比如拖到一个没有cell的空白区域）
// 请注意，在某些情况下，你的建议可能不被系统所允许，此时系统将执行不同的建议
// 你可以通过 -[session locationInView:] 做你自己的命中测试
- (UITableViewDropProposal *)tableView:(UITableView *)tableView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath {
    
    /**
     // TableView江湖接受drop，但是具体的位置还要稍后才能确定T
     // 不会打开一个缺口，也许你可以提供一些视觉上的处理来给用户传达这一信息
     UITableViewDropIntentUnspecified,
     
     // drop 将会插入到目标索引路径
     // 将会打开一个缺口，模拟最后释放后的布局
     UITableViewDropIntentInsertAtDestinationIndexPath,
     
     drop 将会释放在目标索引路径，比如该cell是一个容器（集合），此时不会像 👆 那个属性一样打开缺口，但是该条目标索引对应的cell会高亮显示
     UITableViewDropIntentInsertIntoDestinationIndexPath,
     
     tableView 会根据dro 手势的位置在 .insertAtDestinationIndexPath 和 .insertIntoDestinationIndexPath 自动选择，
     UITableViewDropIntentAutomatic
     */
    UITableViewDropProposal *dropProposal;
    // 如果是另外一个app，localDragSession为nil，此时就要执行copy，通过这个属性判断是否是在当前app中释放，当然只有 iPad 才需要这个适配
    if (session.localDragSession) {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    } else {
        dropProposal = [[UITableViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UITableViewDropIntentInsertAtDestinationIndexPath];
    }
    
    return dropProposal;
}


#pragma mark =============== collectionViewDragView ===================
-(void)addCollectionView{
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    self.collectionView.dragInteractionEnabled = YES;
    self.collectionView.dragDelegate = self;
    self.collectionView.dropDelegate = self;
}

#pragma mark -----------Setters & Getters
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

-(UICollectionViewLayout *)flowLayout{
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}



#pragma mark ---------UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.targetImageView.image = self.dataSource[indexPath.item];
    return cell;
}


#pragma mark ---------UICollectionViewDelegateFlowLayout
//设置item的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(153, 128);
}

//设置item的间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 20;
}

//设置行间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 20;
}

//设置页边距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 20, 0, 20);
}


#pragma mark ---------UICollectionViewDragDelegate

/* 提供一个 给定 indexPath 的可进行 drag 操作的 item（类似 hitTest: 方法周到该响应的view ）
 * 如果返回 nil，则不会发生任何拖拽事件
 */
- (NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath {
    UIImage *image = self.dataSource[indexPath.item];
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:image];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    dragItem.localObject = image;
    return @[dragItem];
    
}

/* 允许对从取消或返回到 CollectionView 的 item 使用自定义预览
 * UIDragPreviewParameters 有两个属性：visiblePath 和 backgroundColor
 * 如果该方法没有实现或者返回nil，那么整个 cell 将用于预览
 */
- (nullable UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dragPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath {
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:5];
    parameters.backgroundColor = [UIColor clearColor];
    return parameters;
}


// 是否接收拖动的item。
- (BOOL)collectionView:(UICollectionView *)collectionView canHandleDropSession:(id<UIDropSession>)session {
    return [session canLoadObjectsOfClass:[UIImage class]];
}



#pragma mark - UICollectionViewDropDelegate
/* 当用户开始进行 drop 操作的时候会调用这个方法
 * 使用 dropCoordinator 去置顶如果处理当前 drop 会话的item 到指定的最终位置，同时也会根据drop item返回的数据更新数据源
 * 如果该方法不做任何事，将会执行默认的动画
 */
- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator {
    // 如果coordinator.destinationIndexPath存在，直接返回；如果不存在，则返回（0，0)位置。
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath ? coordinator.destinationIndexPath : [NSIndexPath indexPathForItem:0 inSection:0];
    
    // 在collectionView内，重新排序时只能拖动一个cell。
    if (coordinator.items.count == 1 && coordinator.items.firstObject.sourceIndexPath) {
        NSIndexPath *sourceIndexPath = coordinator.items.firstObject.sourceIndexPath;
        
        // 将多个操作合并为一个动画。
        [collectionView performBatchUpdates:^{
            // 将拖动内容从数据源删除，插入到新的位置。
            UIImage *image = coordinator.items.firstObject.dragItem.localObject;
            [self.dataSource removeObjectAtIndex:sourceIndexPath.item];
            [self.dataSource insertObject:image atIndex:destinationIndexPath.item];
            
            // 更新collectionView。
            [collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
        } completion:nil];
        
        // 以动画形式移动cell。
        [coordinator dropItem:coordinator.items.firstObject.dragItem toItemAtIndexPath:destinationIndexPath];
    }

}

/* 该方法是提供释放方案的方法，虽然是optional，但是最好实现
 * 当 跟踪 drop 行为在 tableView 空间坐标区域内部时会频繁调用
 * 当drop手势在某个section末端的时候，传递的目标索引路径还不存在（此时 indexPath 等于 该 section 的行数），这时候会追加到该section 的末尾
 * 在某些情况下，目标索引路径可能为空（比如拖到一个没有cell的空白区域）
 * 请注意，在某些情况下，你的建议可能不被系统所允许，此时系统将执行不同的建议
 * 你可以通过 -[session locationInView:] 做你自己的命中测试
 */
- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session withDestinationIndexPath:(nullable NSIndexPath *)destinationIndexPath {

    /**
     CollectionView将会接收drop，但是具体的位置要稍后才能确定
     不会开启一个缺口，可以通过添加视觉效果给用户传达这一信息
     UICollectionViewDropIntentUnspecified,

     drop将会被插入到目标索引中
     将会打开一个缺口，模拟最后释放后的布局
     UICollectionViewDropIntentInsertAtDestinationIndexPath,

     drop 将会释放在目标索引路径，比如该cell是一个容器（集合），此时不会像 👆 那个属性一样打开缺口，但是该条目标索引对应的cell会高亮显示
     UICollectionViewDropIntentInsertIntoDestinationIndexPath,
     */
    UICollectionViewDropProposal *dropProposal;
    // 如果是另外一个app，localDragSession为nil，此时就要执行copy，通过这个属性判断是否是在当前app中释放，当然只有 iPad 才需要这个适配
    if (session.localDragSession) {
        // 拖动手势源自同一app。
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    } else {
        // 拖动手势源自其它app。
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    }
    return dropProposal;
}

@end
