# ZDTableViewBinding

####简介：
ZDTableViewBinding是利用ReactiveCocoa自动处理tableView的数据并计算高度的一个类。
目前只支持单个section。
####ZDTableViewBinding用法:
主要的就一个实例方法和一个类方法

```objc
+ (instancetype)bindingHelperForTableView:(UITableView *)tableView
                           mutableSection:(BOOL)mutableSection
                             sourceSignal:(RACSignal *)sourceSignal
                              cellCommand:(RACCommand *)cellCommand
                           sectionCommand:(RACCommand *)sectionCommand;

- (instancetype)initWithTableView:(UITableView *)tableView
                   mutableSection:(BOOL)mutableSection
                     sourceSignal:(RACSignal *)sourceSignal
                      cellCommand:(RACCommand *)cellCommand
                   sectionCommand:(RACCommand *)sectionCommand;               
```
传参数之前，需要把`cell`和`section`包装成`cellViewModel`、`sectionViewModel`，监听source数据，然后把`sourceSignal`扔给`ZDTableViewBindingHelper`，剩下的事情就不用管了。

cell和section中的控件的响应事件会通过外面`command`的进行操作，比如，每当里面的button被点击了，执行command的execute：方法

```objc
- (IBAction)bottomButtonAction:(UIButton *)sender
{
    NSLog(@"尾视图响应了");
    [self.sectionCommand execute:RACTuplePack(sender, self.sectionModel)];
}
```
然后`bindingHelper`的对应的`command`执行，你可以在`tuple`中参数设置指定的key来判断到底是哪个控件传过来的事件，然后再进行对应的处理操作。

>
如果想单独执行`tableViewDelegate`的某个方法，则需要设置`delegate`,并遵守*`UITableViewDelegate`*相关协议。

---


