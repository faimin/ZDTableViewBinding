[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-iOS-red.svg?style=flat)](#)
[![Language](http://img.shields.io/badge/language-objc-brightgreen.svg?style=flat)](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)
[![](http://img.shields.io/travis/faimin/ZDTableViewBinding.svg?style=flat)](https://travis-ci.org/faimin/ZDTableViewBinding)
![](https://img.shields.io/cocoapods/v/ZDTableViewBinding.svg?style=flat)
![](https://img.shields.io/cocoapods/dt/ZDTableViewBinding.svg)
![](https://img.shields.io/cocoapods/dm/ZDTableViewBinding.svg)
![](https://img.shields.io/cocoapods/dw/ZDTableViewBinding.svg)

# ZDTableViewBinding

#### 简介：

`ZDTableViewBinding`是利用`ReactiveCocoa`自动分发`tableView`的数据并计算高度且缓存的工具，支持`header`和`footer`。

#### ZDTableViewBinding 用法：

主要的就一个实例方法和一个类方法

```objectivec
+ (instancetype)bindingHelperForTableView:(__kindof UITableView *)tableView
                             multiSection:(BOOL)multiSection
                         dataSourceSignal:(__kindof RACSignal *)dataSourceSignal
                              cellCommand:(nullable RACCommand *)cellCommand
                      headerFooterCommand:(nullable RACCommand *)headerFooterCommand
```

传参数之前，需要把`cell`和`section`包装成`cellViewModel`、`sectionViewModel`，监听 source 数据，然后把`sourceSignal`扔给`ZDTableViewBindingHelper`，剩下的事情就不用管了。

cell 和 section 中的控件的响应事件会通过外面的`command`进行操作，比如，当`footer`上的`button`被点击时，执行`RACCommand`的`execute：`方法。

```objectivec
- (IBAction)bottomButtonAction:(UIButton *)sender
{
    NSLog(@"tap footer button");
    [self.headerFooterCommand execute:RACTuplePack(sender, self.sectionModel)];
}
```

然后`bindingHelper`的对应的`command`执行，你可以在`tuple`中参数设置指定的 key 来判断到底是哪个控件传过来的事件，然后再进行对应的处理操作。

如果想单独执行`tableViewDelegate`的某个方法，则需要设置`delegate`，并实现相关协议。

---

### Installation with CocoaPods

Add the following line to your Podfile.

```ruby
pod 'ZDTableViewBinding'
```

Then, run the following command:

```ruby
$ pod install
```

### License

**ZDTableViewBinding** is under an MIT license. See the [LICENSE](https://github.com/faimin/ZDTableViewBinding/blob/master/Demo/LICENSE) file for more information.
