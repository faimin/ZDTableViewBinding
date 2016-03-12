# ZDTableViewBinding

####简介：
ZDTableViewBinding是利用ReactiveCocoa自动处理tableView的数据并计算高度的一个类。
目前只支持单个section。
####ZDTableViewBinding用法:
主要的就一个实例方法和一个类方法

```objc
+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                          estimatedHeight:(CGFloat)estimatedHeight
                             sourceSignal:(RACSignal *)sourceSignal
                         selectionCommand:(RACCommand *)selectCommand;


- (instancetype)initWithTableView:(UITableView *)tableView
                  estimatedHeight:(CGFloat)estimatedHeight
                     sourceSignal:(RACSignal *)sourceSignal
                 selectionCommand:(RACCommand *)selectCommand;                 
```
如果想单独执行TableViewDelegate的某个方法，则需要设置`delegate`,并遵守协议。


