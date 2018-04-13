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

// PS: ViewModel需要实现的协议，为了与cellProtocol区分，协议方法前都加了zd前缀
@protocol ZDCellViewModelProtocol <NSObject>

@property (nonatomic, copy  ) NSString *zd_reuseIdentifier;
@property (nonatomic, copy, nullable) NSString *zd_nibName;
@property (nonatomic, copy, nullable) NSString *zd_className;
@property (nonatomic, strong) id       zd_model;
@property (nonatomic, assign) CGFloat  zd_estimatedHeight;
@property (nonatomic, assign) CGFloat  zd_height;
@property (nonatomic, assign) CGFloat  zd_fixedHeight;
@property (nonatomic, assign) BOOL     zd_canEditRow;
@property (nonatomic, weak  ) ZDTableViewBinding *zd_bindProxy;

@end

//****************************************************************

/// Protocol the tableViewCell need to implement
@protocol ZDCellProtocol <NSObject>

@property (nonatomic, strong) id model;
@property (nonatomic, strong) id<ZDCellViewModelProtocol> viewModel;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, strong, nullable) NSIndexPath *indexPath;
@property (nonatomic, strong) RACCommand *cellCommand;
@property (nonatomic, weak  ) ZDTableViewBinding *bindProxy;

@optional
/// Binds the given viewModel to the view
- (void)bindToCellViewModel:(id<ZDCellViewModelProtocol>)viewModel;

@end

//****************************************************************

@protocol ZDSectionViewModelProtocol <NSObject>

@property (nonatomic, copy  ) NSString *zd_sectionReuseIdentifier;
@property (nonatomic, copy, nullable) NSString *zd_sectionNibName;
@property (nonatomic, copy, nullable) NSString *zd_sectionClassName;
@property (nonatomic, strong) id       zd_sectionModel;
@property (nonatomic, assign) CGFloat  zd_estimatedSectionHeight;
@property (nonatomic, assign) CGFloat  zd_sectionHeight;
@property (nonatomic, assign) CGFloat  zd_sectionFixedHeight;
@property (nonatomic, weak  ) ZDTableViewBinding *zd_sectionBindProxy;

@end

//****************************************************************

@protocol ZDSectionProtocol <NSObject>

@property (nonatomic, strong) id<ZDSectionViewModelProtocol> sectionViewModel;
@property (nonatomic, strong) id sectionModel;
@property (nonatomic, assign) CGFloat sectionHeight;
@property (nonatomic, strong) RACCommand *sectionCommand;
@property (nonatomic, weak  ) ZDTableViewBinding *sectionBindProxy;

@optional
- (void)bindToSectionViewModel:(id<ZDSectionViewModelProtocol>)viewModel;

@end

//****************************************************************

typedef id<ZDCellViewModelProtocol> ZDCellViewModel;
typedef id<ZDCellProtocol> ZDCell;
typedef id<ZDSectionViewModelProtocol> ZDSectionViewModel;
typedef id<ZDSectionProtocol> ZDSection;

//****************************************************************

NS_ASSUME_NONNULL_END


#endif /* ZDBindingProtocols_h */
