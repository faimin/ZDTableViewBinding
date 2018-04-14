//
//  ZDBindingProtocols.h
//  ZDTableViewBinding
//
//  Created by Zero.D.Saber on 2018/3/23.
//

#ifndef ZDBindingProtocols_h
#define ZDBindingProtocols_h

#import <Foundation/Foundation.h>
@class RACCommand, ZDTableViewBinding;

NS_ASSUME_NONNULL_BEGIN

//****************************************************************

// PS: ViewModel需要实现的协议，为了与cellProtocol做区分，协议方法前都加了zd前缀
@protocol ZDCellViewModelProtocol <NSObject>

@property (nonatomic, copy  ) NSString *zd_reuseIdentifier;
@property (nonatomic, copy, nullable) NSString *zd_nibName;
@property (nonatomic, copy, nullable) NSString *zd_className;
@property (nonatomic, strong) id       zd_model;
@property (nonatomic, assign) CGFloat  zd_estimatedHeight;
@property (nonatomic, assign) CGFloat  zd_height;
@property (nonatomic, assign) CGFloat  zd_fixedHeight;
@property (nonatomic, assign) BOOL     zd_canEditRow;
@property (nonatomic, weak  ) ZDTableViewBinding *zd_bindProxy; ///< 在cell创建时赋值,不用外界关心

@end

//****************************************************************

/// Protocol the tableViewCell need to implement
@protocol ZDCellProtocol <NSObject>

@property (nonatomic, strong) id model;
@property (nonatomic, strong) id<ZDCellViewModelProtocol> viewModel;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong, nullable) NSIndexPath *indexPath;
@property (nonatomic, strong) RACCommand *cellCommand;
@property (nonatomic, weak  ) ZDTableViewBinding *bindProxy;    ///< 在cell创建时赋值,不用外界关心

@optional
/// Binds the given viewModel to the view
- (void)bindToCellViewModel:(id<ZDCellViewModelProtocol>)viewModel;

@end

//****************************************************************

@protocol ZDHeaderFooterViewModelProtocol <NSObject>

@property (nonatomic, copy  ) NSString *zd_headerFooterReuseIdentifier;
@property (nonatomic, copy, nullable) NSString *zd_headerFooterNibName;
@property (nonatomic, copy, nullable) NSString *zd_headerFooterClassName;
@property (nonatomic, strong) id       zd_headerFooterModel;
@property (nonatomic, assign) CGFloat  zd_estimatedHeaderFooterHeight;
@property (nonatomic, assign) CGFloat  zd_headerFooterHeight;
@property (nonatomic, assign) CGFloat  zd_headerFooterFixedHeight;
@property (nonatomic, weak, nullable) ZDTableViewBinding *zd_headerFooterBindProxy;  ///< 在section创建时赋值,不用外界关心

@end

//****************************************************************

@protocol ZDHeaderFooterProtocol <NSObject>

@property (nonatomic, strong) id<ZDHeaderFooterViewModelProtocol> headerFooterViewModel;
@property (nonatomic, strong) id headerFooterModel;
@property (nonatomic, assign) CGFloat headerFooterHeight;
@property (nonatomic, strong) RACCommand *headerFooterCommand;
@property (nonatomic, weak, nullable) ZDTableViewBinding *headerFooterBindProxy; ///< 在section创建时赋值,不用外界关心

@optional
- (void)bindToHeaderFooterViewModel:(id<ZDHeaderFooterViewModelProtocol>)viewModel;

@end

//****************************************************************

typedef id<ZDCellViewModelProtocol> ZDCellViewModel;
typedef id<ZDCellProtocol> ZDCell;
typedef id<ZDHeaderFooterViewModelProtocol> ZDHeaderFooterViewModel;
typedef id<ZDHeaderFooterProtocol> ZDHeaderFooter;

//****************************************************************

NS_ASSUME_NONNULL_END


#endif /* ZDBindingProtocols_h */
